import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:asn1_plugin/j2735/2024/basic_safety_message/basic_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_content.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_limit.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_codes.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_itis_codes_and_text.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_phrase.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_text.dart';
import 'package:asn1_plugin/j2735/2024/map_data/map_data.dart';
import 'package:asn1_plugin/j2735/2024/spat/spat.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/exit_service.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/generic_signage.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/work_zone.dart';
import 'package:connection_network_type/connection_network_type.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/models/leidos_date_extraction.dart';
import 'package:cv_mec/models/message_builders/bsm_message_builder.dart';
import 'package:cv_mec/models/protobuf_models/geo_routed_msg.pb.dart' as protobuf;
import 'package:cv_mec/models/itis_code.dart';
import 'package:cv_mec/models/itis_parser.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/imp/registration.dart';
import 'package:cv_mec/models/test_data.dart';
import 'package:cv_mec/models/message_managers/tim_manager.dart';
import 'package:cv_mec/pages/config_page.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/mqtt_service.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fixnum/src/int64.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cv_mec/pages/settings_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'dart:convert';
import 'package:typed_data/typed_data.dart';

class MQTTTesting extends StatefulWidget {
  const MQTTTesting({super.key});

  @override
  _MQTTTestingState createState() => _MQTTTestingState();
}

class _MQTTTestingState extends State<MQTTTesting> {
  final MqttService mqtt = MqttService();
  final ApiService api = ApiService();
  final ASNService asn = ASNService();
  final FileService fileService = FileService();
  final Timing timingService = Get.find<Timing>();
  final GeometryService geometryService = GeometryService();

  ParamController controller = Get.find<ParamController>();
  SettingsController settingsController = Get.find<SettingsController>();
  final ScrollController sendController = ScrollController();
  final ScrollController recController = ScrollController();

  final List<String> receivedLog = [];
  final List<String> appLog = [];

  String param1 = 'Not Set';
  String param2 = 'Not Set';

  String publishTopic = "";
  String subscribeTopic = "";
  String v2xType = "BSM"; //Parameter
  int messageDelay = 1000; // ms Parameter

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool isBroadcastingLocation = false;
  bool isLogging = false;

  DataQueue? recDataQueue;
  DataQueue? pubDataQueue;
  DataQueue? appLogQueue;
  DataQueue? timDataQueue;

  Registration? registration;
  String? mqttConnectionURL;

  late LocationService _locationService;
  StreamSubscription<Position>? _positionStream;
  Position? currentPosition;
  Timer? _timer;

  late Pointer<Pointer<Void>> bsmTemplate;

  BsmMessageBuilder bsmBuilder = BsmMessageBuilder();

  // Map<String, TravelerInformation> receivedTims = <String, TravelerInformation>{};
  TimManager timManager = TimManager();

  ItisParser itisParser = ItisParser();

  _MQTTTestingState() {
    _locationService = Get.find<LocationService>();

    _positionStream = _locationService.locationStream.listen(updatePosition);

    Future.delayed(Duration.zero, () async {
      DateTime logTime = timingService.getKronosTime();

      appLogQueue = DataQueue("APP_LOG_${logTime.millisecondsSinceEpoch}.log");
      timDataQueue = DataQueue("TIM_LOG_${logTime.millisecondsSinceEpoch}.csv");
    });
  }

  @override
  void dispose() {
    if (_positionStream != null) {
      _positionStream!.cancel();
    }
    mqtt.subscriberList.clear();
    mqtt.disconnect();

    if (recDataQueue != null) {
      recDataQueue!.dispose();
    }

    if (pubDataQueue != null) {
      pubDataQueue!.dispose();
    }

    if (appLogQueue != null) {
      appLogQueue!.dispose();
    }

    if (timDataQueue != null) {
      timDataQueue!.dispose();
    }

    super.dispose();
  }

  void _scrollSendToBottom() {
    sendController.animateTo(
      sendController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  void _scrollRecToBottom() {
    recController.animateTo(
      recController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  void startSending() {
    // Stop any previous timer
    _timer?.cancel();
    //_positionStream?.cancel();
    _positionStream = _locationService.locationStream.listen(updatePosition);

    // Set the timer to call _runFunction every 100 milliseconds
    _timer = Timer.periodic(Duration(milliseconds: messageDelay), (timer) {
      sendPosition();

      if (!isConnected()) {
        stopSending();
        if (mounted) {
          setState(() {
            isLogging = false;
            isBroadcastingLocation = false;
          });
        }
      }
    });
  }

  void stopSending() {
    _timer?.cancel();
    //_positionStream?.cancel();
  }

  String getChoiceItemMessage(Choice_Item item) {
    if (item is ITIScodes) {
      return "ITIS: ${(item).itisCode}\n";
    } else if (item is ITIStext) {
      return "Text: ${(item).itisText}\n";
    } else if (item is ITISPhrase) {
      return "Phrase: ${(item).itisPhrase}\n";
    } else {
      return "";
    }
  }

  void onReceieve(MqttReceivedMessage<MqttMessage?> message, DateTime recTime) async {
    final recMess = message.payload as MqttPublishMessage;

    protobuf.GeoRoutedMsg decodedMessage = protobuf.GeoRoutedMsg.fromBuffer(recMess.payload.message);

    DateTime msgTime = timeStampToDateTime(decodedMessage.time);

    String hex = ASNService.bytesToHex(decodedMessage.msgBytes);

    // String hex = utf8.decode(decodedMessage.msgBytes);

    print("Hex Message Test: $hex");

    MsgType msgType = asn.determineHexMessageType(hex);

    String consoleMessage = "";
    DateTime? generationTime;

    if (msgType == MsgType.BSM) {
      consoleMessage =
          "Received BSM Time Delta (ms): ${recTime.millisecondsSinceEpoch - msgTime.millisecondsSinceEpoch}";

      String trimmedHex = asn.trimMessageHeaders(hex, asn.BSM_START_FLAG)!;
      BasicSafetyMessage bsm = asn.decodeBsm(trimmedHex);

      generationTime = bsm.coreData.secMark.getDateTime(recTime);
    } else if (msgType == MsgType.TIM) {
      String trimmedHex = asn.trimMessageHeaders(hex, asn.TIM_START_FLAG)!;
      TravelerInformation tim = asn.decodeTim(trimmedHex);

      generationTime = LeidosDateExtraction.extractDateFromTim(tim);

      timManager.addOrUpdate(tim, hex);

      consoleMessage = "Received TIM with Data: \n{\n";

      for (int i = 0; i < tim.dataFrames.travelerDataFrameList.length; i++) {
        Choice_Content content = tim.dataFrames.travelerDataFrameList[i].content;
        if (content is WorkZone) {
          WorkZone wz = content;
          for (int j = 0; j < wz.item.length; j++) {
            Choice_Item item = wz.item[j];
            consoleMessage = "$consoleMessage  ${getChoiceItemMessage(item)}";
          }
        } else if (content is ExitService) {
          ExitService es = content;
          for (int j = 0; j < es.item.length; j++) {
            Choice_Item item = es.item[j];
            consoleMessage = "$consoleMessage  ${getChoiceItemMessage(item)}";
          }
        } else if (content is GenericSignage) {
          GenericSignage gs = content;
          for (int j = 0; j < gs.item.length; j++) {
            Choice_Item item = gs.item[j];
            consoleMessage = "$consoleMessage  ${getChoiceItemMessage(item)}";
          }
        } else if (content is SpeedLimit) {
          SpeedLimit sl = content;
          for (int j = 0; j < sl.item.length; j++) {
            Choice_Item item = sl.item[j];
            consoleMessage = "$consoleMessage  ${getChoiceItemMessage(item)}";
          }
        } else if (content is ITIS_ITIScodesAndText) {
          ITIS_ITIScodesAndText itis = content;
          for (int j = 0; j < itis.item.length; j++) {
            Choice_Item item = itis.item[j];
            consoleMessage = "$consoleMessage  ${getChoiceItemMessage(item)}";
          }
        }
      }
      consoleMessage = "$consoleMessage}";
    } else if (msgType == MsgType.SPAT) {
      String trimmedHex = asn.trimMessageHeaders(
          hex, asn.SPAT_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
      Spat spat = asn.decodeSpat(trimmedHex);

      if (spat.intersections.intersectionStateList.isNotEmpty) {
        generationTime = spat.intersections.intersectionStateList.first.getUtcTime();
      }

      consoleMessage =
          "Received SPaT Time Delta (ms): ${recTime.millisecondsSinceEpoch - msgTime.millisecondsSinceEpoch}";
    } else if (msgType == MsgType.MAP) {
      String trimmedHex = asn.trimMessageHeaders(
          hex, asn.MAP_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
      MapData map = asn.decodeMap(trimmedHex);
      generationTime = LeidosDateExtraction.extractDateFromMap(map);

      consoleMessage =
          "Received MAP Time Delta (ms): ${recTime.millisecondsSinceEpoch - msgTime.millisecondsSinceEpoch}";
    } else {
      consoleMessage =
          "Received Unknown Message. Time Delta (ms): ${recTime.millisecondsSinceEpoch - msgTime.millisecondsSinceEpoch}";
    }

    if (mounted) {
      setState(() {
        receivedLog.add(consoleMessage);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollRecToBottom();
    });

    if (isLogging) {
      int generationDelta = 0;
      int messageGenerationTime = 0;
      if (generationTime != null) {
        generationDelta = recTime.millisecondsSinceEpoch - generationTime.millisecondsSinceEpoch;
        messageGenerationTime = generationTime.millisecondsSinceEpoch;
      }

      String record =
          "${message.topic}, ${msgType.toString().split('.').last}, ${recTime.millisecondsSinceEpoch},${msgTime.millisecondsSinceEpoch},$messageGenerationTime,${recTime.millisecondsSinceEpoch - msgTime.millisecondsSinceEpoch},$generationDelta,${decodedMessage.position.longitude},${decodedMessage.position.latitude},$mqttConnectionURL,$hex\n";
      if (recDataQueue != null) {
        recDataQueue!.addItem(record);
      }
    }
  }

  void sendPosition() async {
    if (isBroadcastingLocation) {
      protobuf.GeoRoutedMsg msg = protobuf.GeoRoutedMsg();

      protobuf.Position pos = protobuf.Position();

      if (currentPosition != null && !controller.useFakePositionToggle.value) {
        pos.longitude = currentPosition!.longitude;
        pos.latitude = currentPosition!.latitude;
      } else {
        pos.latitude = controller.fakeLatitude.value;
        pos.longitude = controller.fakeLongitude.value;
      }

      DateTime sendTime = timingService.getKronosTime();

      Uint8Buffer buffer = Uint8Buffer();
      msg.position = pos;

      bsmBuilder.setPositionLatLng(pos.latitude, pos.longitude);
      bsmBuilder.incrementMsgCnt();
      bsmBuilder.setTime(sendTime);

      // msg.msgBytes = utf8.encode(asn.encode(bsmTemplate));

      String hex = bsmBuilder.build();

      msg.msgBytes = ASNService.hexToBytes(hex);

      msg.time = dateTimeToTimestamp(sendTime);

      buffer.addAll(msg.writeToBuffer());

      int messageID = mqtt.publishBytes(buffer, publishTopic);
      addToAppLog("Sent: ${sendTime.millisecondsSinceEpoch}");
      if (isLogging) {
        if (pubDataQueue != null) {
          String record =
              "$publishTopic,${sendTime.millisecondsSinceEpoch},${pos.longitude},${pos.latitude},$mqttConnectionURL,$hex\n";
          pubDataQueue!.addItem(record);
        }
      }
    }
  }

  void updatePosition(Position position) {
    currentPosition = position;
    List<TravelerDataFrame> newActiveTims =
        timManager.getNewActiveTims(position.longitude, position.latitude, position.heading);
    showTimMessage(newActiveTims);
  }

  void addToAppLog(String message) {
    if (mounted) {
      print("Mounted Setting State");
      setState(() {
        appLog.add(message);
        if (appLogQueue != null) {
          String timedMessage = "${DateTime.now().toIso8601String()}, $message \n";
          appLogQueue!.addItem(timedMessage);
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollSendToBottom();
      });
    }
  }

  void addToTimLog(String operation, String message) {
    // Position includePosition = Position()
    // if(currentPosition!= null){

    // }

    // timDataQueue.addItem("${DateTime.now().millisecondsSinceEpoch}, ${currentPosition!.longitude}, ${currentPosition!.latitude}")
  }

  void getPermission() async {
    print("went HERE");
    await Geolocator.requestPermission();
  }

  void deleteRegistration() async {
    //await fileService.requestPermissions();
    bool didDelete = await fileService.deleteRegistration();
    registration = null;
    if (didDelete) {
      addToAppLog("Deleted Registration Cache");
    } else {
      addToAppLog("No Registration Cache to delete");
    }
  }

  void getClientInfo(MqttReceivedMessage<MqttMessage?> message, DateTime recTime) async {
    final recMess = message.payload as MqttPublishMessage;
    // session_id = msg.payload.decode("utf-8")["SessionID"]

    String msg = utf8.decode(recMess.payload.message);
    Map<String, dynamic> clientInfo = json.decode(msg);

    if (clientInfo.containsKey("SessionID")) {
      publishTopic =
          "vzimp/1/Private/${clientInfo["SessionID"]}/${controller.clientType}/${controller.clientSubtype}/${settingsController.vendorID.value}/${controller.messageFormat}/$v2xType";
    }
  }

  void connectToMqttBroker() async {
    timingService.startAllUpdates();
    if (mqttConnectionURL != null && registration != null) {
      int result = await mqtt.connect(mqttConnectionURL!, registration!);

      if (result == 0) {
        addToAppLog("Connected to MQTT Broker");

        if (controller.geoRelevanceOrPrivate) {
          if (controller.privateDeviceID == "self") {
            mqtt.subscribe("vzimp/1/ClientInfo", getClientInfo);

            // publishTopic =
            //     "vzimp/1/Private/${registration!.deviceID}/${controller.clientType}/${controller.clientSubtype}/${settingsController.vendorID.value}/${controller.messageFormat}/$v2xType";
          } else {
            publishTopic =
                "vzimp/1/Private/${controller.privateDeviceID}/${controller.clientType}/${controller.clientSubtype}/${settingsController.vendorID.value}/${controller.messageFormat}/$v2xType";
          }

          subscribeTopic = "vzimp/1/Private/+/+/+/${controller.messageFormat.value}/+/+";
        } else {
          publishTopic =
              "vzimp/1/GeoRelevance/${controller.clientType.value}/${controller.clientSubtype.value}/Public/${controller.messageFormat}/$v2xType";
          subscribeTopic = "vzimp/1/GeoRelevance/+/+/Public/${controller.messageFormat}/+/+";
        }

        addToAppLog("Publish Topic $publishTopic");
        mqtt.subscribe(subscribeTopic, onReceieve);
        addToAppLog("Subscribed to Topic $subscribeTopic");
      } else {
        addToAppLog("Failed to connect to MQTT Broker");
      }
    } else {
      addToAppLog("MQTT Connection is not available because the connection URL or Registration are missing");
    }
  }

  void showTimMessage(List<TravelerDataFrame> newActiveTims) async {
    for (TravelerDataFrame dataFrame in newActiveTims) {
      addToAppLog("Showing Tim from ASN.1");

      ItisCode displayCode = await itisParser.getItisRepresentation(dataFrame);

      addToAppLog("Showing TIM: ${displayCode.itis}, ${displayCode.status}");

      Color borderColor = Colors.blue;

      if (displayCode.status == ITIS_CODE_STATUS.VALID) {
        borderColor = Colors.green;
      } else if (displayCode.status == ITIS_CODE_STATUS.UNKNOWN) {
        borderColor = Colors.yellow;
      } else if (displayCode.status == ITIS_CODE_STATUS.ERROR) {
        borderColor = Colors.red;
      }

      ToastificationItem? item;
      item = toastification.showCustom(
        context: context, // optional if you use ToastificationWrapper
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.topCenter,
        animationDuration: const Duration(milliseconds: 500),
        builder: (BuildContext context, ToastificationItem holder) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(color: borderColor, width: 2.0),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Traveler Information Message',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (displayCode.image != null)
                      Expanded(
                          child: Image(
                        image: displayCode.image!,
                      ))
                    else
                      Expanded(
                        child: Text(displayCode.description, style: const TextStyle(color: Colors.black)),
                      )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: ToastTimerAnimationBuilder(
                      item: item!,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(value: value);
                      },
                    )),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        toastification.dismiss(item!);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void toggleConnection() {
    if (registration != null) {
      if (isConnected()) {
        disconnect();
      } else {
        connectToMqttBroker();
      }
    }
  }

  void test() async {
    // final tim = asn.decodeTim(asn.testTimTemplate);
    final tim = asn.decodeTim(TestData.shopTestTim);

    timManager.addOrUpdate(tim, TestData.shopTestTim);
    // List<TravelerDataFrame> frames = timManager.getNewActiveTims(-104.9691448,40.4743463, 0); // Shop TIM
    // List<TravelerDataFrame> frames = timManager.getNewActiveTims(-104.6469010, 41.1530501, 0); // Archer Speed
    // List<TravelerDataFrame> frames = timManager.getNewActiveTims(-104.6599010, 41.14733501, 0); // Archer Reduce Speed
    // List<TravelerDataFrame> frames = timManager.getNewActiveTims(-104.6580462, 41.147105668, 0); // testRightLaneClosedAhead 41.147105668, -104.6580462
    // List<TravelerDataFrame> frames = timManager.getNewActiveTims(-104.6485760, 41.1477001, 30); // testWorkzoneTim 41.1477001,-104.6485760

    // showTimMessage(frames);
  }

  void toggleBroadcasting() async {
    if (mounted) {
      setState(() {
        isBroadcastingLocation = !isBroadcastingLocation;
      });
    }

    if (isBroadcastingLocation) {
      startSending();
    } else {
      stopSending();
    }
  }

  void toggleLogging() async {
    if (mounted) {
      setState(() {
        isLogging = !isLogging;
      });
    }

    if ((isLogging && Platform.isIOS) || (isLogging && await Permission.phone.request().isGranted)) {
      // await Permission.manageExternalStorage.isGranted;
      // await fileService.requestPermissions();

      DateTime logTime = timingService.getKronosTime();

      recDataQueue = DataQueue("MQTT_SUB_LOG_${logTime.millisecondsSinceEpoch}.csv");
      pubDataQueue = DataQueue("MQTT_PUB_LOG_${logTime.millisecondsSinceEpoch}.csv");
      addToAppLog("Saving Records to ${recDataQueue!.fileName}");
      String subHeader =
          "topic,message_type,receive_time_ms,send_time_ms,generation_time_ms,send_rec_delta_time_ms,gen_rec_delta_time_ms,longitude,latitude,broker,msg_bytes\n";

      recDataQueue!.addItem(subHeader);

      String pubHeader = "Topic, Send Time ms, Longitude, Latitude, Network, Broker, Msg Bytes\n";
      pubDataQueue!.addItem(pubHeader);
    } else {}
  }

  void disconnect() async {
    mqtt.disconnect();
    mqtt.subscriberList.clear();
    addToAppLog("Disconnected from Broker");
  }

  bool isConnected() {
    return mqtt.client != null && mqtt.client!.connectionStatus!.state == MqttConnectionState.connected;
  }

  Future<String> getNetworkField() async {
    String networkType = "UNKNOWN";
    String signalStrength = "NONE_OR_UNKNOWN";

    return "$networkType $signalStrength";
  }

  String enumToString(Object o) => o.toString().split('.').last;

  protobuf.Timestamp dateTimeToTimestamp(DateTime dateTime) {
    protobuf.Timestamp time = protobuf.Timestamp();
    time.seconds = Int64(dateTime.millisecondsSinceEpoch ~/ 1000);
    time.nanos = (dateTime.millisecond * 1E6 + dateTime.microsecond * 1000).toInt();
    return time;
  }

  DateTime timeStampToDateTime(protobuf.Timestamp timeStamp) {
    DateTime dt =
        DateTime.fromMicrosecondsSinceEpoch((timeStamp.seconds.toInt() * 1E6).toInt() + timeStamp.nanos ~/ 1000);
    return dt;
  }

  @override
  Widget build(BuildContext context) {
    const String appTitle = "CV-MEC";
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Get.back();
              }),
          title: const Text(appTitle),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Get.to(() => SettingsPage());
                }),
          ],
        ),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Get.dialog(ConfigDialogTwo()),
              /*_openConfigDialog*/
              child: const Text('Configure MQTT Connection'),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () async {
                  //fileService.requestPermissions();
                  addToAppLog("Getting Token from Server");
                  String? token = await api.getToken();
                  print("Got Token $token");
                  addToAppLog("Retrieving Certificates");

                  if (token != null) {
                    // if (await fileService.checkIfRegistrationExists()) {
                    //   addToAppLog("Loading Registration from Cache");
                    //   registration = await fileService.getRegistration();
                    // } else {
                    addToAppLog("Loading Registration from Server");
                    registration =
                        await api.getRegistration(token, controller.clientType.value, controller.clientSubtype.value);
                    // }
                    if (registration != null) {
                      fileService.saveRegistration(registration!);
                      addToAppLog("Acquired Certificates for DeviceID: ${registration!.deviceID}");
                      mqttConnectionURL = await api.getConnection(token, registration!.deviceID,
                          controller.fakeLatitude.value, controller.fakeLongitude.value, controller.networkType.value);
                      addToAppLog("Acquired MQTT Connection String: $mqttConnectionURL");
                    } else {
                      addToAppLog("Failed to Register application");
                    }
                  } else {
                    addToAppLog("Unable to authenticate with Vendor API");
                  }
                },
                child: const Text('Register Device'),
              ),
              // ElevatedButton(
              //   onPressed: deleteRegistration,
              //   child: Text("Delete Registration"),
              // ),
            ]),
            ElevatedButton(
              onPressed: registration != null ? toggleConnection : null,
              child: Text(!isConnected() ? "Connect" : "Disconnect"),
            ),
            ElevatedButton(
              onPressed: mqtt.client != null && mqtt.client!.connectionStatus!.state == MqttConnectionState.connected
                  ? toggleBroadcasting
                  : null,
              child: Text(isBroadcastingLocation ? "Stop Broadcasting" : "Start Broadcasting"),
            ),
            ElevatedButton(
              onPressed: isConnected() ? toggleLogging : null,
              child: Text(!isLogging ? 'Start Logging' : "Stop Logging"),
            ),
            // ElevatedButton(
            //   onPressed: test,
            //   child: Text("Test"),
            // ),
            const Text("Send Message Log"),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  controller: sendController,
                  itemCount: appLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(appLog[index]),
                    );
                  },
                ),
              ),
            ),
            const Text("Received Message Log"),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  controller: recController,
                  itemCount: receivedLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(receivedLog[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        )));
  }
}
