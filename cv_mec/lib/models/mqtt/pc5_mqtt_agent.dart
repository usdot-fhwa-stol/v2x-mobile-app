import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/mqtt/mqtt_agent.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:get/get.dart';
import 'package:iss_scms/models/psid.dart';
import 'package:typed_data/typed_data.dart';

class Pc5MqttAgent extends MqttAgent{

  // Ettifos OBU MQTT API topic prefix.
  // Received PC5 messages are published by the OBU on  $topicPrefix/ind/J2735/{PSID}
  // Messages published by the app on $topicPrefix/req/J2735/{PSID} are broadcast by the OBU over PC5
  static const String topicPrefix = "Ettifos/V2X";

  SettingsController settingsController = Get.find<SettingsController>();
  ASNService asnService = Get.find<ASNService>();
  final Set<MsgType> _unsupportedTypesLogged = {};

  Pc5MqttAgent(Function(String?, String, List<int>, DateTime, DateTime?, String) processingFunction): super("PC5", processingFunction);

  @override
  Future<int> connect() async{
    connectionUrl = settingsController.pc5BrokerUrl.value;
    int result = await mqttService.connect(settingsController.pc5BrokerUrl.value, null);
    return result;
  }

  @override
  Future<int> setupSubscribers() async{
    print("Subscribing to PC5 Topics");
    mqttService.subscribe("$topicPrefix/ind/J2735/#", callback);
    return 0;
  }

  @override
  String sendMessage(List<int> message, MsgType messageType, DateTime sendTime){
    int psid;
    switch (messageType) {
      case MsgType.BSM:
        psid = PSID.BSM.code;
        break;
      case MsgType.PSM:
        psid = PSID.PSM.code;
        break;
      default:
        // Only log once per type, this function is called at the broadcast rate
        if (_unsupportedTypesLogged.add(messageType)) {
          loggingService.addToAppLog('$agentName does not support sending ${messageType.name} messages');
        }
        return "";
    }

    // The OBU expects a bare UPER encoded J2735 MessageFrame. It adds the WSMP / 1609.2 layers itself.
    List<int>? messageFrame = _extractMessageFrame(message, messageType);
    if (messageFrame == null) {
      loggingService.showWarning("$agentName unable to extract ${messageType.name} MessageFrame. Message not sent.");
      return "";
    }

    String topic = "$topicPrefix/req/J2735/$psid";

    Uint8Buffer buffer = Uint8Buffer();
    buffer.addAll(messageFrame);
    mqttService.publishBytes(buffer, topic);
    return topic;
  }

  // Returns the UPER encoded MessageFrame contained in [bytes].
  // [bytes] may already be a bare MessageFrame, or may be wrapped in a 1609.2 signed envelope
  // (when SCMS signing is enabled), in which case the header and signature trailer are removed.
  // Returns null if no valid MessageFrame can be found.
  List<int>? _extractMessageFrame(List<int> bytes, MsgType messageType) {
    String? startFlag = asnService.getStartFlagForMessageType(messageType);
    if (startFlag == null || startFlag.isEmpty) {
      return null;
    }

    int hexIndex = asnService.findValidStartFlagLocation(ASNService.bytesToHex(bytes).toUpperCase(), startFlag);
    if (hexIndex < 0) {
      return null;
    }
    int start = hexIndex ~/ 2;

    // MessageFrame layout: 2 byte DSRCmsgID, UPER length determinant (1 or 2 bytes), message value
    int lengthIndex = start + 2;
    if (lengthIndex >= bytes.length) {
      return null;
    }

    int length;
    int lengthBytes;
    int firstLengthByte = bytes[lengthIndex];
    if ((firstLengthByte & 0x80) == 0) {
      length = firstLengthByte;
      lengthBytes = 1;
    } else if ((firstLengthByte & 0xC0) == 0x80) {
      if (lengthIndex + 1 >= bytes.length) {
        return null;
      }
      length = ((firstLengthByte & 0x3F) << 8) | bytes[lengthIndex + 1];
      lengthBytes = 2;
    } else {
      // Fragmented encoding (length >= 16384), not expected for BSM / PSM
      return null;
    }

    int end = lengthIndex + lengthBytes + length;
    if (end > bytes.length) {
      return null;
    }
    return bytes.sublist(start, end);
  }

  @override
  Future<int> updateSubscribers() async{
    return 0;
  }
}
