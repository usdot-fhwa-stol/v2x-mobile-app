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

  /// Connects this PC5 MQTT agent.
  ///
  /// Returns:
  /// - `0`: Connected successfully.
  /// - `non-zero`: the result code from the [MqttService.connect] method indicating the connect failure type
  @override
  Future<int> connect() async{
    connectionUrl = settingsController.pc5BrokerUrl.value;
    int result = await mqttService.connect(settingsController.pc5BrokerUrl.value, null);
    return result;
  }

  /// Sets up the subscribers for this PC5 MQTT agent.
  /// Returns:
  /// - `0`: Subscribers set up successfully.
  @override
  Future<int> setupSubscribers() async{
    print("Subscribing to PC5 Topics");
    mqttService.subscribe("$topicPrefix/ind/J2735/#", callback);
    return 0;
  }

  /// Sends a BSM or PSM over PC5 by publishing it to the connected Ettifos OBU, which rebroadcasts it.
  /// The message is published as a bare UPER encoded J2735 MessageFrame to $topicPrefix/req/J2735/{PSID},
  /// where PSID is in decimal (e.g. BSM = 32). Any 1609.2 envelope is removed since the OBU adds its own.
  ///
  /// Parameters:
  /// - `message`: The message payload as a list of bytes. May be a bare MessageFrame or 1609.2 signed.
  /// - `messageType`: The type of the message. Only [MsgType.BSM] and [MsgType.PSM] are supported.
  /// - `sendTime`: The time the message is sent.
  ///
  /// Returns:
  /// - The topic the message was published to, or an empty string if the message was not sent.
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
          loggingService.logInfo('$agentName does not support sending ${messageType.name} messages');
        }
        return "";
    }

    // The OBU expects a bare UPER encoded J2735 MessageFrame. It adds the WSMP / 1609.2 layers itself.
    List<int>? messageFrame = asnService.extractMessageFrame(message, messageType);
    if (messageFrame == null) {
      loggingService.logWarning("$agentName unable to extract ${messageType.name} MessageFrame. Message not sent.");
      return "";
    }

    String topic = "$topicPrefix/req/J2735/$psid";

    Uint8Buffer buffer = Uint8Buffer();
    buffer.addAll(messageFrame);
    mqttService.publishBytes(buffer, topic);
    return topic;
  }

  /// Updates the subscribers for this PC5 MQTT agent. This method is not required for the PC5 interface as it does not dynamically change subscriptions.
  /// Returns:
  /// - `0`: Subscribers updated successfully.
  @override
  Future<int> updateSubscribers() async{
    return 0;
  }
}
