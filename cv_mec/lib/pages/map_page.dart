import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:asn1_plugin/j2735/2024/basic_safety_message/basic_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/bsmpart_iiextension.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/special_vehicle_extensions.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/supplemental_vehicle_extensions.dart';
import 'package:asn1_plugin/j2735/2024/common/basic_vehicle_class.dart';
import 'package:asn1_plugin/j2735/2024/common/d_day.dart';
import 'package:asn1_plugin/j2735/2024/common/d_hour.dart';
import 'package:asn1_plugin/j2735/2024/common/d_minute.dart';
import 'package:asn1_plugin/j2735/2024/common/d_month.dart';
import 'package:asn1_plugin/j2735/2024/common/d_second.dart';
import 'package:asn1_plugin/j2735/2024/common/d_year.dart';
import 'package:asn1_plugin/j2735/2024/common/lightbar_in_use.dart';
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/node_set_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/siren_in_use.dart';
import 'package:asn1_plugin/j2735/2024/map_data/generic_lane.dart';
import 'package:asn1_plugin/j2735/2024/map_data/map_data.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/detected_object_data.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/sensor_data_sharing_message.dart';
import 'package:asn1_plugin/j2735/2024/spat/intersection_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_event.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_phase_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/spat.dart';
import 'package:asn1_plugin/j2735/2024/spat/time_mark.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:connection_network_type/connection_network_type.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/models/geometry_direction.dart';
import 'package:cv_mec/models/icon_manager.dart';
import 'package:cv_mec/models/itis_converter.dart';
import 'package:cv_mec/models/data_frame_geometry.dart';
import 'package:cv_mec/models/geo_map.dart';
import 'package:cv_mec/models/itis_code.dart';
import 'package:cv_mec/models/leidos_date_extraction.dart';
import 'package:cv_mec/models/message_builders/bsm_message_builder.dart';
import 'package:cv_mec/models/message_builders/psm_message_builder.dart';
import 'package:cv_mec/models/message_managers/map_manager.dart';
import 'package:cv_mec/models/message_managers/received_message_manager.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/imp/registration.dart';
import 'package:cv_mec/models/received_messages/receieved_msg.dart';
import 'package:cv_mec/models/received_messages/received_bsm.dart';
import 'package:cv_mec/models/received_messages/received_psm.dart';
import 'package:cv_mec/models/received_messages/received_sdsm.dart';
import 'package:cv_mec/models/render_models/render_lane_connection.dart';
import 'package:cv_mec/models/render_models/render_light_location.dart';
import 'package:cv_mec/models/message_managers/spat_manager.dart';
import 'package:cv_mec/models/test_data.dart';
import 'package:cv_mec/models/message_managers/tim_manager.dart';
import 'package:cv_mec/models/type_definitions.dart';
import 'package:cv_mec/models/light_change_time.dart';
import 'package:cv_mec/models/utils.dart';
import 'package:cv_mec/models/vehicle.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/mqtt_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/secure_storage.dart';
import 'package:cv_mec/services/vehicle_notification_manager.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/appbar.dart';
import 'package:flutter/foundation.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cv_mec/models/protobuf_models/geo_routed_msg.pb.dart' as protobuf;
import 'package:typed_data/typed_data.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:asn1_plugin/j2735/2024/common/siren_in_use.dart';

enum ConnectedStatus { UNKNOWN, DISCONNECTED, CONNECTED, PARTIAl }

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapState createState() => MapState();
}

class MapState extends State<MapPage> {
  late MapController _mapController;

  ParamController paramController = Get.find<ParamController>();
  GeometryService geometryService = Get.find<GeometryService>();
  ASNService asnService = Get.find<ASNService>();
  ApiService apiService = Get.find<ApiService>();
  Timing timingService = Get.find<Timing>();
  FileService fileService = Get.find<FileService>();
  MqttService mqtt = Get.find<MqttService>();
  LocationService locationService = Get.find<LocationService>();
  SettingsController settingsController = Get.find<SettingsController>();
  S3Service awsService = Get.find<S3Service>();
  ConfigurationController configController = Get.find<ConfigurationController>();

  TimManager timManager = TimManager();
  MapManager mapManager = MapManager();
  SpatManager spatManager = SpatManager();
  ReceivedMessageManager messageManager = ReceivedMessageManager();

  SecureStorage secureStorage = SecureStorage();

  Registration? registration;
  String? mqttConnectionURL;
  Position? currentPosition;

  late String publishTopic;
  late String publicGeoRelevanceRawSubscribeTopic;
  late String publicGeoRelevanceSubscribeTopic;
  late String privateSubscribeTopic;
  late String privateRawSubscribeTopic;

  Timer? sendMessageTimer;
  late BsmMessageBuilder bsmBuilder;
  late PsmMessageBuilder psmBuilder;

  Timer? uploadTimer;

  Color connectedButtonColor = Colors.red;
  StreamSubscription<Position>? positionStream;

  List<ItisCode> showTims = [];
  List<Polygon<HitValue>> drawnPolygons = [];
  List<Polyline<PolyLineHitValue>> drawnPolylines = [];
  List<Marker> lightMarkerList = [];

  bool followUser = true;

  late DataQueue recDataQueue;
  late DataQueue pubDataQueue;
  late DataQueue appLogQueue;
  late DataQueue timDataQueue;

  final LayerHitNotifier<HitValue> _hitNotifier = ValueNotifier(null);
  List<HitValue>? _prevHitValues;
  List<Polygon<HitValue>>? _hoverGons;

  late FlutterTts flutterTts;

  final Map<MovementPhaseState, Image> lightStateMap = {
    MovementPhaseState.UNAVAILABLE: Image.asset("assets/images/Lights/traffic-light-icon-unknown.png"),
    MovementPhaseState.DARK: Image.asset("assets/images/Lights/traffic-light-icon-unknown.png"),
    MovementPhaseState.STOP_THEN_PROCEED: Image.asset("assets/images/Lights/traffic-light-icon-red-flashing.png"),
    MovementPhaseState.STOP_AND_REMAIN: Image.asset("assets/images/Lights/traffic-light-icon-red.png"),
    MovementPhaseState.PRE_MOVEMENT: Image.asset("assets/images/Lights/traffic-light-yellow-red.png"),
    MovementPhaseState.PERMISSIVE_MOVEMENT_ALLOWED: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png"),
    MovementPhaseState.PROTECTED_MOVEMENT_ALLOWED: Image.asset("assets/images/Lights/traffic-light-icon-green.png"),
    MovementPhaseState.PROTECTED_CLEARANCE: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png"),
    MovementPhaseState.PERMISSIVE_CLEARANCE: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png"),
    MovementPhaseState.CAUTION_CONFLICTING_TRAFFIC: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png")
  };

  late Image currentLightState;
  late String nextLightText = "";

  bool debugMode = true;
  bool showLoadingIcon = true;
  bool showLightText = true;

  @override
  void initState() {
    super.initState();
    showLoadingIcon = true;

    _mapController = MapController();
    timingService.startAllUpdates();

    bsmBuilder = BsmMessageBuilder();
    psmBuilder = PsmMessageBuilder();

    if (configController.isVehicleConfig.value) {
      publishTopic =
          "vzimp/1/GeoRelevance/${paramController.clientType.value}/${paramController.clientSubtype.value}/Public/${paramController.messageFormat}/BSM";
    } else {
      publishTopic =
          "vzimp/1/GeoRelevance/${paramController.clientType.value}/${paramController.clientSubtype.value}/Public/${paramController.messageFormat}/PSM";
    }

    publicGeoRelevanceSubscribeTopic = "vzimp/1/GeoRelevance/+/+/Public/j2735_gr/+/+";
    publicGeoRelevanceRawSubscribeTopic = "vzimp/1/GeoRelevance/+/+/Public/j2735/+/+";

    privateSubscribeTopic = "vzimp/1/Private/+/+/+/j2735_gr/+/+";
    privateRawSubscribeTopic = "vzimp/1/Private/+/+/+/j2735/+/+";

    currentLightState = lightStateMap[MovementPhaseState.UNAVAILABLE]!;

    if (debugMode) {
      // TravelerInformation tim =
      //     asnService.decodeTim(TestData.pedestrianCrossingTim);
      // timManager.addOrUpdate(tim, TestData.pedestrianCrossingTim);

      // TravelerInformation tim2 = asnService.decodeTim(asnService.verizonTim2);
      // timManager.addOrUpdate(tim2, asnService.verizonTim2);

      // TravelerInformation tim3 = asnService.decodeTim(asnService.longQueueTim);
      // timManager.addOrUpdate(tim3, asnService.queueTim);
      // TravelerInformation tim4 = asnService.decodeTim(asnService.testTimTemplate);
      // timManager.addOrUpdate(tim4, asnService.testTimTemplate);

      // MapData map = asnService.decodeMap(TestData.cdotTestMap12110);
      // PersonalSafetyMessage psm = asnService.decodePsm(TestData.testPsm);

      // mapManager.addOrUpdate(map);

      // fakeSpatMessages(TestData.tfhrcFakeSpats);

      // SensorDataSharingMessage sdsm = asnService.decodeSdsm(TestData.sampleSDSM);
      fakeSdsmMessage();
    } else if (settingsController.demoMode.value) {
      // TravelerInformation weatherTimDemo = asnService.decodeTim(TestData.tfhrcWeatherTIMDemo);
      // timManager.addOrUpdate(weatherTimDemo, TestData.tfhrcWeatherTIMDemo);

      // TravelerInformation vslTimDemo = asnService.decodeTim(TestData.tfhrcVSLTIMDemo);
      // timManager.addOrUpdate(vslTimDemo, TestData.tfhrcWeatherTIMDemo);
    }

    flutterTts = FlutterTts();

    Future.delayed(Duration.zero, () async {
      int loggingEnabled = await enableLogging();
      if (loggingEnabled != 0) {
        return;
      }

      int connected = await connectToMqttBroker();
      if (connected != 0) {
        return;
      }

      updateConnectedStatus(ConnectedStatus.CONNECTED);

      if (debugMode) {
        // tfhrcStaticPosition
        positionStream = fakePosition(TestData.tfhrcFakePosition).listen(updatePosition);
      } else if (settingsController.demoMode.value) {
        positionStream = fakePosition(TestData.tfhrcFakePosition).listen(updatePosition);
      } else {
        positionStream = locationService.locationStream.listen(updatePosition);
      }

      if (Platform.isIOS) {
        await flutterTts.setSharedInstance(true);

        await flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.ambient,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers
            ],
            IosTextToSpeechAudioMode.voicePrompt);
      }
    });

    if (mounted) {
      setState(() {
        drawnPolygons = getPolygons();
        drawnPolylines = getPolylines();
        showLoadingIcon = true;
      });
    }
  }

  @override
  void dispose() {
    configController.stopSiren();
    configController.isBusWarningOn.value = false;
    super.dispose();
  }

  void fakeSpatMessages(List<String> fakeSpats) {
    int spatSimStartTime = timingService.getKronosTime().toUtc().millisecondsSinceEpoch;
    int yearStartMs = DateTime(timingService.getKronosTime().year, 1, 1).millisecondsSinceEpoch;

    int revision = 0;

    int minEndTime = 0;
    int maxEndTime = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      DateTime now = timingService.getKronosTime().toUtc().subtract(DateTime.now().timeZoneOffset);

      int deltaMs = (now.millisecondsSinceEpoch - spatSimStartTime);

      int index = (deltaMs ~/ 100) % fakeSpats.length;

      if ((deltaMs ~/ 100) % 600 == 0) {
        minEndTime = now.minute * 600 + now.second * 10 + 300;
        maxEndTime = now.minute * 600 + now.second * 10 + 350;
      }

      Spat spat = asnService.decodeSpat(fakeSpats[index]);

      spat.timeStamp = MinuteOfTheYear((now.millisecondsSinceEpoch - yearStartMs) ~/ 60000);

      for (IntersectionState state in spat.intersections.intersectionStateList) {
        state.moy = spat.timeStamp;
        state.timeStamp = DSecond(now.second * 1000 + now.millisecond);
        state.revision = MsgCount(revision);

        for (MovementState movementState in state.states.movementList) {
          for (MovementEvent event in movementState.state_time_speed.movementEventList) {
            if (event.timing != null) {
              event.timing!.minEndTime = TimeMark(minEndTime);
              event.timing!.maxEndTime = TimeMark(maxEndTime);
            }
          }
        }
      }

      revision = (revision + 1) % 127;
      spatManager.addOrUpdate(spat);

      await Future.delayed(const Duration(milliseconds: 100)); // Simulate an async task
    });
  }

  void fakeSdsmMessage() {
    SensorDataSharingMessage sdsm = asnService.decodeSdsm(TestData.tfhrcSDSM);
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      DateTime now = timingService.getKronosTime();
      processNewSdsm(publicGeoRelevanceSubscribeTopic, TestData.tfhrcSDSM, now, now);
      // await Future.delayed(const Duration(milliseconds: 100)); // Simulate an async task
    });
  }

  Stream<Position> fakePosition(List<List<double>> fakePosition) {
    return Stream<Position>.periodic(const Duration(milliseconds: 500), (count) {
      List<List<double>> route = fakePosition; //fakePosition.reversed.toList();
      int index = count % route.length;
      int prevIndex = (count - 1) % route.length;

      List<double> pos = route[index];
      List<double> lastPos = route[prevIndex];

      double heading = radianToDeg(atan2(pos[1] - lastPos[1], pos[0] - lastPos[0]));

      num distance =
          geometryService.geodesy.distanceBetweenTwoGeoPoints(LatLng(pos[1], pos[0]), LatLng(lastPos[1], lastPos[0]));

      double speed = distance / 0.5;

      heading = -heading + 90;
      if (heading < 0) {
        heading += 360;
      }

      return Position(
          longitude: route[index][0],
          latitude: route[index][1],
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 1600,
          altitudeAccuracy: 0,
          heading: heading,
          headingAccuracy: 0,
          speed: speed,
          speedAccuracy: 0);
    });
  }

  Future<int> enableLogging() async {
    DateTime logTime = timingService.getKronosTime();

    recDataQueue = DataQueue("MQTT_SUB_LOG_${logTime.millisecondsSinceEpoch}.csv");
    pubDataQueue = DataQueue("MQTT_PUB_LOG_${logTime.millisecondsSinceEpoch}.csv");
    appLogQueue = DataQueue("APP_LOG_${logTime.millisecondsSinceEpoch}.log");
    timDataQueue = DataQueue("TIM_LOG_${logTime.millisecondsSinceEpoch}.csv");
    String subHeader =
        "topic,message_type,receive_time_ms,send_time_ms,generation_time_ms,send_rec_delta_time_ms,gen_rec_delta_time_ms,longitude,latitude,broker,msg_bytes\n";
    String pubHeader = "topic,send_time_ms,longitude,latitude,broker,msg_bytes\n";
    String timHeader = "action,time,longitude,latitude,heading,asn1\n";

    recDataQueue.addItem(subHeader);
    pubDataQueue.addItem(pubHeader);
    timDataQueue.addItem(timHeader);

    uploadTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      uploadAllLogs();
    });

    return 0;
  }

  Future<int> connectToMqttBroker() async {
    String? token = await apiService.getToken();

    if (mounted) {
      setState(() {
        showLoadingIcon = true;
      });
    }

    updateConnectedStatus(ConnectedStatus.PARTIAl);

    if (token == null) {
      showError("Unable to retrieve token from partner API. Please verify partner API credentials in settings menu");
      return 1;
    }

    //Add Loading Registration from Cache
    if (await fileService.checkIfRegistrationExists()) {
      addToAppLog("Loading Registration from Cache");
      registration = await fileService.getRegistration();
    } else {
      addToAppLog("Loading Registration from Server");
      registration = await apiService.getRegistration(
          token, paramController.clientType.value, paramController.clientSubtype.value);

      if (registration != null) {
        fileService.saveRegistration(registration!);
      }
    }

    if (registration == null) {
      showError("Unable to retrieve registration information from partner API");
      return 2;
    }

    addToAppLog("Acquired Certificates for DeviceID: ${registration!.deviceID}");

    String vzString = paramController.networkType.value;

    if (settingsController.vzMode.value) {
      vzString = "VZ";
    } else {
      vzString = "non-VZ";
    }

    mqttConnectionURL = await apiService.getConnection(token, registration!.deviceID,
        paramController.fakeLatitude.value, paramController.fakeLongitude.value, vzString);

    int result = await mqtt.connect(mqttConnectionURL!, registration!);
    if (result != 0) {
      showError("Unable to Connect to MQTT Broker");
      return 3;
    }

    mqtt.subscribe(privateRawSubscribeTopic, onRawAsnMessage); //MAP / TIM
    mqtt.subscribe(privateSubscribeTopic, onGeoRelevanceMessage);
    mqtt.subscribe(publicGeoRelevanceRawSubscribeTopic, onRawAsnMessage); // SPaT
    mqtt.subscribe(publicGeoRelevanceSubscribeTopic, onGeoRelevanceMessage);

    //cdotFakePosition

    startSendingBSM();
    WakelockPlus.enable();

    if (mounted) {
      setState(() {
        showLoadingIcon = false;
      });
    }

    return 0;
  }

  void onGeoRelevanceMessage(MqttReceivedMessage<MqttMessage?> message, DateTime recTime) async {
    addToAppLog("Received Geo Relevance Message");

    final recMess = message.payload as MqttPublishMessage;

    protobuf.GeoRoutedMsg decodedMessage = protobuf.GeoRoutedMsg.fromBuffer(recMess.payload.message);

    DateTime msgTime = Utils.timeStampToDateTime(decodedMessage.time);

    addToAppLog("${decodedMessage.position.longitude}, ${decodedMessage.position.latitude}");

    String hex = ASNService.bytesToHex(decodedMessage.msgBytes);

    processIncomingMessage(message.topic, hex, recTime, msgTime);
  }

  void onRawAsnMessage(MqttReceivedMessage<MqttMessage?> message, DateTime recTime) {
    addToAppLog("Received ASN1 Message");
    final recMess = message.payload as MqttPublishMessage;
    String hex = ASNService.bytesToHex(recMess.payload.message);
    processIncomingMessage(message.topic, hex, recTime, null);
  }

  void processIncomingMessage(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    MsgType msgType = asnService.determineHexMessageType(hex);

    if (msgType == MsgType.BSM) {
      addToAppLog("Identified Message as BSM");
      processNewBsm(topic, hex, recTime, sendTime);
    } else if (msgType == MsgType.PSM) {
      addToAppLog("Identified Message as PSM");
      processNewPsm(topic, hex, recTime, sendTime);
    } else if (msgType == MsgType.SPAT) {
      addToAppLog("Identified Message as SPaT");
      processNewSpat(topic, hex, recTime, sendTime);
    } else if (msgType == MsgType.MAP) {
      addToAppLog("Identified Message as MAP");
      processNewMap(topic, hex, recTime, sendTime);
    } else if (msgType == MsgType.TIM) {
      addToAppLog("Identified Message as TIM");
      processNewTim(topic, hex, recTime, sendTime);
    } else if (msgType == MsgType.SDSM) {
      addToAppLog("Identified Message as SDSM");
      processNewSdsm(topic, hex, recTime, sendTime);
    } else {
      addToAppLog("Unable to Identify Message Type");
    }
  }

  void processNewBsm(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    VehicleClass vehicleClass = VehicleClass.unknownVehicleClass;

    String trimmedHex = asnService.trimMessageHeaders(hex, asnService.BSM_START_FLAG)!;
    BasicSafetyMessage bsm = asnService.decodeBsm(trimmedHex);

    LightbarInUse lights = LightbarInUse.unavailable;
    SirenInUse sirens = SirenInUse.unavailable;
    if (bsm.partII != null) {
      for (BSMpartIIExtension ext in bsm.partII!) {
        if (ext is SupplementalVehicleExtensions) {
          if (ext.classification != null) {
            vehicleClass = ext.classification!.getVehicleClass();
          }
        } else if (ext is SpecialVehicleExtensions) {
          if (ext.vehicleAlerts != null) {
            lights = ext.vehicleAlerts!.lightsUse;
            sirens = ext.vehicleAlerts!.sirenUse;
          }
        }
      }
    }
    LatLng position = LatLng(bsm.coreData.lat.getDecimalLatitude(), bsm.coreData.long.getDecimalLongitude());
    String vehicleID = ASNService.bytesToHex(bsm.coreData.id.temporaryID);

    DateTime bsmTime = bsm.coreData.secMark.getDateTime(recTime);

    ReceivedMsg msg = ReceivedBsm(vehicleID, bsmTime, position, vehicleClass, lights, sirens);
    messageManager.addOrUpdate(msg);
    addToReceiveLog(topic, "BSM", recTime, sendTime, bsmTime, trimmedHex);
  }

  void processNewPsm(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    String trimmedHex = asnService.trimMessageHeaders(hex, asnService.PSM_START_FLAG)!;
    PersonalSafetyMessage psm = asnService.decodePsm(trimmedHex);

    LatLng position = LatLng(psm.position.lat.getDecimalLatitude(), psm.position.long.getDecimalLongitude());
    String pedestrianID = ASNService.bytesToHex(psm.id.temporaryID);

    DateTime psmTime = psm.secMark.getDateTime(recTime);

    ReceivedMsg msg = ReceivedPsm(pedestrianID, psmTime, position, psm.basicType, psm.eventResponderType);
    messageManager.addOrUpdate(msg);
    addToReceiveLog(topic, "PSM", recTime, sendTime, psmTime, trimmedHex);
  }

  void processNewSpat(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.SPAT_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    Spat spat = asnService.decodeSpat(trimmedHex);

    spatManager.addOrUpdate(spat);

    if (mounted) {
      setState(() {
        drawnPolygons = getPolygons();
        drawnPolylines = getPolylines();
      });
    }
    DateTime? spatGenTime;
    if (spat.intersections.intersectionStateList.isNotEmpty) {
      spatGenTime = spat.intersections.intersectionStateList.first.getUtcTime();
    }

    addToReceiveLog(topic, "SPAT", recTime, sendTime, spatGenTime, trimmedHex);
  }

  void processNewMap(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.MAP_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    MapData map = asnService.decodeMap(trimmedHex);

    mapManager.addOrUpdate(map);

    if (mounted) {
      setState(() {
        drawnPolygons = getPolygons();
        drawnPolylines = getPolylines();
      });
    }

    addToReceiveLog(topic, "MAP", recTime, sendTime, LeidosDateExtraction.extractDateFromMap(map), trimmedHex);
  }

  void processNewTim(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.TIM_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    TravelerInformation tim = asnService.decodeTim(trimmedHex);

    timManager.addOrUpdate(tim, hex);
    if (mounted) {
      setState(() {
        drawnPolygons = getPolygons();
        drawnPolylines = getPolylines();
      });
    }
    DateTime? generationTime = LeidosDateExtraction.extractDateFromTim(tim);

    Future.delayed(const Duration(milliseconds: 0), () async {
      String messageType = "TIM";
      if (tim.dataFrames.travelerDataFrameList.isNotEmpty) {
        ItisCode code = await timManager.getItisRepresentationForDataFrame(tim.dataFrames.travelerDataFrameList.first);
        messageType = "TIM ${code.description}";
      }

      addToReceiveLog(topic, messageType, recTime, sendTime, generationTime, trimmedHex);
    });
  }

  void processNewSdsm(String topic, String hex, DateTime recTime, DateTime? sendTime) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.SDSM_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    SensorDataSharingMessage sdsm = asnService.decodeSdsm(trimmedHex);
    // sdsmManager.addOrUpdateWithTime(sdsm, hex, recTime);
    sdsm.sDSMTimeStamp.year ??= DYear(recTime.year);
    sdsm.sDSMTimeStamp.month ??= DMonth(recTime.month);
    sdsm.sDSMTimeStamp.day ??= DDay(recTime.day);
    sdsm.sDSMTimeStamp.hour ??= DHour(recTime.hour);
    sdsm.sDSMTimeStamp.minute ??= DMinute(recTime.minute);
    sdsm.sDSMTimeStamp.second ??= DSecond(recTime.second);

    LatLng refPos = LatLng(sdsm.refPos.lat.getDecimalLatitude(), sdsm.refPos.long.getDecimalLongitude());
    int msgCount = sdsm.msgCnt.msgCount;

    for (DetectedObjectData object in sdsm.objects.objects) {
      String id = "${sdsm.sourceID}_${object.detObjCommon.objectID.objectID}";
      DateTime objectTime =
          recTime.add(Duration(milliseconds: object.detObjCommon.measurementTime.mesurementTimeOffset));

      geometryService.shiftLatLng(refPos, object.detObjCommon.pos.offsetX.getDistanceInMeters(),
          object.detObjCommon.pos.offsetY.getDistanceInMeters());
      messageManager.addOrUpdate(ReceivedSdsm(id, objectTime, refPos, object.detObjCommon.objType));
    }

    addToReceiveLog(topic, "SDSM", recTime, sendTime, sdsm.sDSMTimeStamp.getAsDateTime(), trimmedHex);
  }

  void addToReceiveLog(
      String topic, String msgType, DateTime recTime, DateTime? sendTime, DateTime? generationTime, String hex) async {
    int delta = 0;
    int logSendTime = 0;
    if (sendTime != null) {
      delta = recTime.millisecondsSinceEpoch - sendTime.millisecondsSinceEpoch;
      logSendTime = sendTime.millisecondsSinceEpoch;
    }

    int generationDelta = 0;
    int messageGenerationTime = 0;
    if (generationTime != null) {
      generationDelta = recTime.millisecondsSinceEpoch - generationTime.millisecondsSinceEpoch;
      messageGenerationTime = generationTime.millisecondsSinceEpoch;
    }

    double longitude = 0;
    double latitude = 0;
    if (currentPosition != null) {
      longitude = currentPosition!.longitude;
      latitude = currentPosition!.latitude;
    }

    String record =
        "$topic, ${msgType.toString().split('.').last}, ${recTime.millisecondsSinceEpoch},$logSendTime,$messageGenerationTime,$delta,$generationDelta,$longitude,$latitude,$mqttConnectionURL,$hex\n";
    recDataQueue.addItem(record);
  }

  void showError(String message) {
    addToAppLog("ERROR: $message");
    // TODO
  }

  void addToAppLog(String message) {
    print("APPLOG: $message");
    appLogQueue.addItem("$message\n");
  }

  void startSendingBSM() {
    // Stop any previous timer
    sendMessageTimer?.cancel();

    // Set the timer to call _runFunction every 100 milliseconds
    sendMessageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      sendMessage();
      if (!isConnected()) {
        stopSendingBSM();
        onMqttDisconnect();
      }
    });
  }

  void sendMessage() async {
    protobuf.GeoRoutedMsg msg = protobuf.GeoRoutedMsg();
    protobuf.Position pos = protobuf.Position();
    if (currentPosition == null) {
      addToAppLog("Cannot Send BSM. Location is Null");
      updateConnectedStatus(ConnectedStatus.PARTIAl);
      return;
    }

    DateTime sendTime = timingService.getKronosTime();

    Uint8Buffer buffer = Uint8Buffer();
    msg.position = pos;
    String hex = "";

    pos.latitude = currentPosition!.latitude;
    pos.longitude = currentPosition!.longitude;

    // Switch to PSM messages depending on config settings.
    if (configController.isVehicleConfig.value) {
      bsmBuilder.setPosition(currentPosition!);
      bsmBuilder.incrementMsgCnt();
      bsmBuilder.setTime(sendTime);

      bsmBuilder.setVehicleClass(
          BasicVehicleClass(VehicleType.toVehicleClass(configController.selectedVehicle.value.classification).code));

      LightbarInUse lightStatus = LightbarInUse.unavailable;
      SirenInUse sirenUse = SirenInUse.unavailable;

      if (configController.isBusWarningOn.value) {
        lightStatus = LightbarInUse.inUse;
      }

      if (configController.isSirenOn.value) {
        sirenUse = SirenInUse.inUse;
      }

      bsmBuilder.setEmergencyVehicleLights(lightStatus, sirenUse);

      hex = bsmBuilder.build();
    } else {
      psmBuilder.setPosition(currentPosition!);
      psmBuilder.incrementMsgCnt();
      psmBuilder.setTime(sendTime);
      psmBuilder.setPersonalDeviceUserType(configController.selectedPedestrian);
      hex = psmBuilder.build();
    }

    if (hex != "") {
      msg.msgBytes = ASNService.hexToBytes(hex);
      msg.time = Utils.dateTimeToTimestamp(sendTime);
      buffer.addAll(msg.writeToBuffer());
      mqtt.publishBytes(buffer, publishTopic);
      updateConnectedStatus(ConnectedStatus.CONNECTED);
      NetworkStatus networkStatus = await ConnectionNetworkType().currentNetworkStatus();
    }

    String netStat = "Unavailable";
    String record =
        "$publishTopic,${sendTime.millisecondsSinceEpoch},${currentPosition!.longitude},${currentPosition!.latitude},$netStat,$mqttConnectionURL,$hex\n";
    pubDataQueue.addItem(record);
  }

  void stopSendingBSM() {
    sendMessageTimer?.cancel();
  }

  DateTime prevNtp = DateTime.now();
  DateTime prevKronos = DateTime.now();
  DateTime prevLocal = DateTime.now();

  Future<void> updatePosition(Position position) async {
    currentPosition = position;

    DateTime now = DateTime.now();

    DateTime ntp = timingService.getNtpTime();
    DateTime kronos = timingService.getKronosTime();

    prevNtp = ntp;
    prevKronos = kronos;
    prevLocal = now;

    if (mounted) {
      setState(() {
        drawnPolygons = getPolygons();
        drawnPolylines = getPolylines();
      });
    }

    if (followUser) {
      _mapController.moveAndRotate(getUserLocation(), _mapController.camera.zoom, _mapController.camera.rotation);
    }

    List<TravelerDataFrame> newActiveTims = [];
    List<ReceivedMsg> newReceivedMessages = messageManager.getNewReceivedMessages(
        LatLng(currentPosition!.latitude, currentPosition!.longitude), currentPosition!.heading);
    List<ItisCode> receivedMessageItisCodes = messageManager.convertToItisCodes(newReceivedMessages);

    secureStorage.getNotificationsEnabled().then((enabled) {
      if (enabled) {
        timManager.getItisRepresentationForDataFrames(newActiveTims).then((codes) async {
          for (ItisCode code in codes) {
            await VehicleNotificationManager.notifyVehicleFromItisCode(code);
          }
        });

        for (ItisCode code in receivedMessageItisCodes) {
          VehicleNotificationManager.notifyVehicleFromDescriptionImage(code.description, code.image!);
        }
      }
    });

    secureStorage.getReadMessages().then((enabled) {
      if (enabled) {
        timManager.getItisRepresentationForDataFrames(newActiveTims).then((codes) async {
          for (ItisCode code in codes) {
            String message = ItisConverter.getItisListAsString(code.associatedCodes);
            await flutterTts.speak(message);
          }

          for (ItisCode code in receivedMessageItisCodes) {
            await flutterTts.speak(code.description);
          }
        });
      }
    });

    List<TravelerDataFrame> frames = [];

    // if speed is less than 1 meter / second (~2.2 mph)
    if (position.speed < 1) {
      newActiveTims = timManager.getNewActiveTims(
          position.longitude, position.latitude, position.heading, true, settingsController.demoMode.value);

      frames = timManager.getTimsToShow(
          position.longitude, position.latitude, position.heading, true, settingsController.demoMode.value);
    } else {
      newActiveTims = timManager.getNewActiveTims(
          position.longitude, position.latitude, position.heading, false, settingsController.demoMode.value);

      frames = timManager.getTimsToShow(
          position.longitude, position.latitude, position.heading, false, settingsController.demoMode.value);
    }

    updateTimeToChange();

    List<ItisCode> codes = await timManager.getItisRepresentationForDataFrames(frames);
    List<ItisCode> msgs = messageManager.convertToItisCodes(
        messageManager.getActiveMessages(LatLng(position.latitude, position.longitude), position.heading));

    List<String> hex = timManager.getUniqueAsnFromDataFrames(frames);
    for (String str in hex) {
      addToTimLog("ALERT", str);
    }

    codes.addAll(msgs);

    if (mounted) {
      setState(() {
        showTims = codes;
      });
    }
    // showTimMessage(newActiveTims);
  }

  void onMqttDisconnect() {
    showError("Disconnected from MQTT Broker Randomly");
    updateConnectedStatus(ConnectedStatus.DISCONNECTED);
    stopSendingBSM();
    mqtt.subscriberList.clear();
    WakelockPlus.disable();
    uploadTimer?.cancel();
  }

  bool isConnected() {
    return mqtt.client != null && mqtt.client!.connectionStatus!.state == MqttConnectionState.connected;
  }

  LatLng getUserLocation() {
    if (currentPosition != null) {
      return LatLng(currentPosition!.latitude, currentPosition!.longitude);
    } else {
      return LatLng(paramController.fakeLatitude.value, paramController.fakeLongitude.value);
    }
  }

  void updateConnectedStatus(ConnectedStatus status) {
    if (mounted) {
      setState(() {
        if (status == ConnectedStatus.UNKNOWN) {
          connectedButtonColor = Colors.grey;
        } else if (status == ConnectedStatus.CONNECTED) {
          connectedButtonColor = Colors.green;
        } else if (status == ConnectedStatus.DISCONNECTED) {
          connectedButtonColor = Colors.red;
        } else if (status == ConnectedStatus.PARTIAl) {
          connectedButtonColor = Colors.orange;
        }
      });
    }
  }

  void updateTimeToChange() {
    DateTime now = timingService.getKronosTime();
    LightChangeTime? next;
    Position? pos = currentPosition;
    if (pos != null) {
      List<GeoMap> geoMaps = mapManager.getActiveMaps(pos.longitude, pos.latitude);

      for (GeoMap map in geoMaps) {
        List<int> activeLaneIds = mapManager.getActiveLaneIds(map, pos.longitude, pos.latitude);

        // if(activeLaneIds.isNotEmpty){
        List<int> signalGroups = [];
        for (int activeLane in activeLaneIds) {
          if (map.laneSignalGroups.containsKey(activeLane)) {
            signalGroups.addAll(map.laneSignalGroups[activeLane]!);
          }
        }

        for (int signalGroup in signalGroups) {
          LightChangeTime? timing =
              spatManager.getNextLaneTimeChange(map.intersectionGeometry.id.id.intersectionID, signalGroup, now);
          if (timing != null) {
            if (next == null || timing.minEndTime.isBefore(next.minEndTime)) {
              next = timing;
            }
          }
        }
      }

      if (next != null) {
        String text = "";
        if (next.likelyTime != null) {
          int nextExpectedChange = (next.likelyTime!.millisecondsSinceEpoch - now.millisecondsSinceEpoch) ~/ 1000;
          text = "$nextExpectedChange S";
          if (nextExpectedChange > 60) {
            text = "Change in:\n > 1\n Minute";
          } else if (nextExpectedChange < 0) {
            text = "Changing Now";
          }
        } else if (next.maxEndTime != null) {
          int expectedMaxTime = (next.maxEndTime!.millisecondsSinceEpoch - now.millisecondsSinceEpoch) ~/ 1000;
          int expectedMinTime = (next.minEndTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch) ~/ 1000;

          text = "Change in:\n $expectedMinTime - $expectedMaxTime\n Seconds";
          if (expectedMinTime > 60) {
            text = "Change in:\n > 1\n Minute";
          } else if (expectedMinTime < 0) {
            text = "Changing Now";
          }
        } else {
          int expectedMinTime = (next.minEndTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch) ~/ 1000;
          text = "> $expectedMinTime Seconds";
          if (expectedMinTime > 60) {
            text = "Change in:\n > 1\n Minute";
          } else if (expectedMinTime < 0) {
            text = "Changing Now";
          }
        }

        if (mounted) {
          setState(() {
            currentLightState = lightStateMap[next!.currentPhaseState]!;
            nextLightText = text;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            currentLightState = lightStateMap[MovementPhaseState.UNAVAILABLE]!;
            nextLightText = "";
          });
        }
      }
    }
  }

  List<Marker> getMarkerList() {
    List<Marker> markerList = [];

    Position? pos = currentPosition;

    if (pos != null) {
      if (_mapController.camera.zoom > 17.5) {
        // Get Maps that the user is near or in
        List<GeoMap> geoMaps = mapManager.getActiveMaps(pos.longitude, pos.latitude);

        for (GeoMap map in geoMaps) {
          // Get SPaT messages associated with the relavent MAP messages
          List<IntersectionState> states =
              spatManager.getActiveSpats(map.intersectionGeometry.id.id.intersectionID, timingService.getKronosTime());

          for (IntersectionState state in states) {
            // This code indexes light colors by signal group to allow easy lookup down the line
            Map<int, MovementEvent> stateMap = {};
            for (MovementState movement in state.states.movementList) {
              if (movement.state_time_speed.movementEventList.isNotEmpty) {
                stateMap[movement.signalGroup.signalGroupID] = movement.state_time_speed.movementEventList.first;
              }
            }

            for (RenderLightLocation lightLocation in map.lightLocations.values) {
              MovementPhaseState dominantState = MovementPhaseState.UNAVAILABLE;
              for (int signalGroup in lightLocation.signalGroups) {
                if (stateMap.containsKey(signalGroup)) {
                  dominantState = getDominantMovementPhaseState(stateMap[signalGroup]!.eventState, dominantState);
                }
              }
              markerList.add(Marker(
                width: 20.0,
                height: 40.0,
                point: lightLocation.coordinate,
                child: lightStateMap[dominantState] ??
                    const Icon(
                      Icons.traffic,
                      color: Colors.grey,
                    ),
              ));
            }
          }
        }
      }

      Marker userMarker = Marker(
        point: getUserLocation(),
        width: 60,
        height: 60,
        child: iconBase(getSenderIcon(), Colors.blue[900]!,
            sirensOn: configController.isSirenOn.value, busWarningOn: configController.isBusWarningOn.value),
      );

      markerList.add(userMarker);
    }

    DateTime compTime = timingService.getKronosTime();
    DateTime endTime = compTime.add(const Duration(seconds: 1));
    DateTime startTime = compTime.subtract(const Duration(seconds: 1));

    List<String> removeKeys = [];
    for (String key in messageManager.receivedMsgs.keys) {
      ReceivedMsg msg = messageManager.receivedMsgs[key]!;

      if (msg.dateTime.isAfter(startTime) && msg.dateTime.isBefore(endTime)) {
        if (msg is ReceivedBsm) {
          Marker remoteMarker = Marker(
            point: msg.position,
            width: 60,
            height: 60,
            child: iconBase(IconManager.getReceivedMessageIcon(msg), Colors.grey[700]!,
                sirensOn: msg.sirens == SirenInUse.inUse, busWarningOn: msg.lights == LightbarInUse.inUse),
          );
          markerList.add(remoteMarker);
        } else {
          Marker remoteMarker = Marker(
            point: msg.position,
            width: 60,
            height: 60,
            child: iconBase(IconManager.getReceivedMessageIcon(msg), Colors.grey[700]!),
          );
          markerList.add(remoteMarker);
        }
      } else {
        removeKeys.add(key);
      }
    }

    for (String key in removeKeys) {
      messageManager.receivedMsgs.remove(key);
      if (messageManager.shown.containsKey(key)) {
        messageManager.shown.remove(key);
      }
    }
    return markerList;
  }

  IconData getSenderIcon() {
    if (configController.isVehicleConfig()) {
      return IconManager.getIconForBSM(configController.selectedVehicle.value.classification);
    } else {
      return IconManager.getIconForPSM(
          configController.selectedPedestrian, configController.selectedPublicSafetyWorker);
    }
  }

  Widget iconBase(IconData icon, Color color, {bool sirensOn = false, bool busWarningOn = false}) {
    sendMessageTimer;
    return sirensOn
        ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              //color: Colors.red,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.8), Colors.red, Colors.transparent],
                stops: [0.4, 0.6, 1.0], // Adjust the gradient spread
              ),
            ),
            child: Icon(
              icon,
              size: 25,
              color: color,
            ),
          )
        : busWarningOn
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //color: Colors.red,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.8), Colors.orange, Colors.transparent],
                    stops: [0.4, 0.6, 1.0], // Adjust the gradient spread
                  ),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: color,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 25,
                    color: color,
                  ),
                ),
              );
  }

  MovementPhaseState getDominantMovementPhaseState(MovementPhaseState a, MovementPhaseState b) {
    final priorityOrder = [
      MovementPhaseState.PROTECTED_MOVEMENT_ALLOWED,
      MovementPhaseState.PROTECTED_CLEARANCE,
      MovementPhaseState.PERMISSIVE_MOVEMENT_ALLOWED,
      MovementPhaseState.PERMISSIVE_CLEARANCE,
      MovementPhaseState.STOP_AND_REMAIN,
      MovementPhaseState.STOP_THEN_PROCEED,
      MovementPhaseState.PRE_MOVEMENT,
      MovementPhaseState.CAUTION_CONFLICTING_TRAFFIC,
      MovementPhaseState.DARK,
      MovementPhaseState.UNAVAILABLE,
    ];

    if (priorityOrder.indexOf(a) < priorityOrder.indexOf(b)) {
      return a;
    } else {
      return b;
    }
  }

  List<Polyline<PolyLineHitValue>> getPolylines() {
    List<Polyline<PolyLineHitValue>> polylines = [];

    Position? pos = currentPosition;

    if (pos != null) {
      // Get Maps that the user is near or in
      List<GeoMap> geoMaps = mapManager.getActiveMaps(pos.longitude, pos.latitude);

      for (GeoMap map in geoMaps) {
        // Get SPaT messages associated with the relavent MAP messages
        List<IntersectionState> states =
            spatManager.getActiveSpats(map.intersectionGeometry.id.id.intersectionID, timingService.getKronosTime());

        for (IntersectionState state in states) {
          // This code indexes light colors by signal group to allow easy lookup down the line
          Map<int, MovementEvent> stateMap = {};
          for (MovementState movement in state.states.movementList) {
            if (movement.state_time_speed.movementEventList.isNotEmpty) {
              stateMap[movement.signalGroup.signalGroupID] = movement.state_time_speed.movementEventList.first;
            }
          }

          // Iterate over the pre-calculated lines and assign each connection a color
          for (RenderLaneConnection connection in map.laneConnections) {
            Color connectionColor = Colors.grey;
            StrokePattern pattern = const StrokePattern.dotted();
            if (stateMap.containsKey(connection.signalGroup)) {
              MovementPhaseState lightState = stateMap[connection.signalGroup]!.eventState;

              if (lightState == MovementPhaseState.DARK) {
                connectionColor = Colors.grey.shade900;
                pattern = const StrokePattern.dotted();
              } else if (lightState == MovementPhaseState.STOP_THEN_PROCEED) {
                connectionColor = Colors.red;
                pattern = const StrokePattern.dotted();
              } else if (lightState == MovementPhaseState.STOP_AND_REMAIN) {
                connectionColor = Colors.red;
                pattern = const StrokePattern.solid();
              } else if (lightState == MovementPhaseState.PRE_MOVEMENT) {
                connectionColor = Colors.orange;
                pattern = const StrokePattern.dotted();
              } else if (lightState == MovementPhaseState.PERMISSIVE_MOVEMENT_ALLOWED) {
                connectionColor = Colors.green;
                pattern = const StrokePattern.dotted();
              } else if (lightState == MovementPhaseState.PROTECTED_MOVEMENT_ALLOWED) {
                connectionColor = Colors.green;
                pattern = const StrokePattern.solid();
              } else if (lightState == MovementPhaseState.PROTECTED_CLEARANCE) {
                connectionColor = Colors.yellow;
                pattern = const StrokePattern.solid();
              } else if (lightState == MovementPhaseState.CAUTION_CONFLICTING_TRAFFIC) {
                connectionColor = Colors.orange;
                pattern = const StrokePattern.solid();
              } else if (lightState == MovementPhaseState.PERMISSIVE_CLEARANCE) {
                connectionColor = Colors.yellow;
                pattern = const StrokePattern.dotted();
              }
            }

            Polyline<PolyLineHitValue> hitPoly = Polyline(
                points: connection.coordinates,
                borderColor: connectionColor,
                color: connectionColor,
                borderStrokeWidth: 1,
                strokeWidth: 1,
                hitValue: (name: "Connection ${polylines.length}"),
                pattern: pattern);

            polylines.add(hitPoly);
          }
        }

        for (GenericLane lane in map.intersectionGeometry.laneSet.laneList) {
          List<LatLng> laneCoordinates = geometryService.getLatLngCoordinatesFromNodeSetXY(
              lane.nodeList.nodeListXY as NodeSetXY, map.intersectionGeometry.refPoint);

          // Adds Ingress and Egress Map Lanes
          Color laneColor = Colors.blue.shade900;
          if (lane.ingressApproach != null) {
            laneColor = Colors.pink.shade300;
          }

          Polyline<PolyLineHitValue> hitPoly = Polyline(
            points: laneCoordinates,
            borderColor: laneColor,
            color: laneColor,
            borderStrokeWidth: 1,
            strokeWidth: 1,
            hitValue: (name: "Lane: ${lane.laneID}"),
          );
          polylines.add(hitPoly);
        }
      }
    }

    return polylines;
  }

  List<Polygon<HitValue>> getPolygons() {
    List<Polygon<HitValue>> polygons = [];

    List<DataFrameGeometry> dataFrames = timManager.getActiveTimGeometry(true);

    for (DataFrameGeometry frame in dataFrames) {
      TravelerDataFrame tdFrame = frame.frame;

      // ItisCode code = await timManager.getItisRepresentationForDataFrame(tdFrame);

      for (GeometryDirection geoDir in frame.geometry) {
        List<LatLng> polyPoints = geometryService.convertGeometryToLatLngList(geoDir.geometry);

        Polygon<HitValue> hitPoly = Polygon(
          points: polyPoints,
          borderColor: Colors.orangeAccent,
          color: const Color.fromARGB(128, 252, 173, 89),
          borderStrokeWidth: 1,
          hitValue: (frame: tdFrame,),
        );

        polygons.add(hitPoly);
      }
    }

    // // Uncomment this to show the polygon region in the forward arc
    // if (currentPosition != null && currentPosition!.speed > 5) {
    //   List<LatLng> polygon = geometryService.convertGeometryToLatLngList(geometryService.getConicSectionProjection(
    //       LatLng(currentPosition!.latitude, currentPosition!.longitude), currentPosition!.heading, 10, 90, 100));

    //   polygon.remove(polygon.last);
    //   Polygon<HitValue> hitPoly = Polygon(
    //     points: polygon,
    //     borderColor: Colors.greenAccent,
    //     color: const Color.fromARGB(128, 252, 173, 89),
    //     borderStrokeWidth: 1,
    //   );
    //   polygons.add(hitPoly);
    // }

    return polygons;
  }

  addToTimLog(String action, String asn1) {
    if (currentPosition != null) {
      timDataQueue.addItem(
          "$action, ${timingService.getKronosTime().millisecondsSinceEpoch}, ${currentPosition!.longitude}, ${currentPosition!.latitude}, ${currentPosition!.heading}, $asn1\n");
    } else {
      timDataQueue.addItem("$action, ${timingService.getKronosTime().millisecondsSinceEpoch}, 0, 0, 0, $asn1\n");
    }
  }

  void uploadAllLogs() {
    if (settingsController.deviceID.value.isNotEmpty) {
      awsService.uploadFile(recDataQueue.filePath, "subscribe/${settingsController.deviceID.value}");
      awsService.uploadFile(pubDataQueue.filePath, "publish/${settingsController.deviceID.value}");
      awsService.uploadFile(pubDataQueue.filePath, "tim/${settingsController.deviceID.value}");
      awsService.uploadFile(pubDataQueue.filePath, "app/${settingsController.deviceID.value}");
    } else if (registration != null) {
      awsService.uploadFile(recDataQueue.filePath, "subscribe/${registration!.deviceID}");
      awsService.uploadFile(pubDataQueue.filePath, "publish/${registration!.deviceID}");
      awsService.uploadFile(pubDataQueue.filePath, "tim/${registration!.deviceID}");
      awsService.uploadFile(pubDataQueue.filePath, "app/${registration!.deviceID}");
    } else {
      addToAppLog("Cannot Upload Logs - Device ID is Unavailable");
    }
  }

  String enumToString(Object o) => o.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const String appTitle = "MAP";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              sendMessageTimer?.cancel();
              positionStream?.cancel();
              uploadTimer?.cancel();
              mqtt.disconnect();

              Future.delayed(const Duration(milliseconds: 100), () async {
                Get.back();
              });
            }),
        title: const Text(appTitle),
        actions: <Widget>[
          navigationMenu(context),
        ],
      ),
      body: Stack(alignment: AlignmentDirectional.topStart, children: [
        Center(child: map(context, _mapController)),
        Align(
          alignment: Alignment.topRight,
          child: showLightText && nextLightText.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                      width: screenWidth * 0.20,
                      // height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow.shade600, width: 2.0), // Box border
                        borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                        color: Colors.grey.shade800, // Optional: Background color
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text("Current Light State",
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        SizedBox(width: screenWidth * 0.15, height: screenHeight * 0.15, child: currentLightState),
                        Text(nextLightText, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                      ])))
              : (!showLightText && nextLightText.isNotEmpty)
                  ? SizedBox(width: screenWidth * 0.15, height: screenHeight * 0.15, child: currentLightState)
                  : Container(),
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                managementButtons(),
                verticalSpaceSmall,
                configController.hasASiren()
                    ? sirenButton()
                    : configController.isABus()
                        ? busWarningButton()
                        : Container(width: 60),
              ]),
            )),
        Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 170,
              child: Row(children: [
                Expanded(
                  child: timsDisplay(),
                ),
                configController.isVehicleConfig.value ? speedMarker() : Container(),
              ]),
            )),
        Align(
          alignment: Alignment.center,
          child: showLoadingIcon
              ? const SpinKitSpinningLines(
                  color: Colors.white,
                  size: 140,
                  lineWidth: 4,
                )
              : null,
        )
      ]),
    );
  }

  Widget map(BuildContext context, MapController mapController) {
    return Obx(
      () => SizedBox(
        // width: screenWidthPercentage(context, percentage: orientation == Orientation.portrait ? 0.8 : 0.4),
        // height: screenHeightPercentage(context, percentage: orientation == Orientation.portrait ? 0.45 : 0.7),
        child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(paramController.fakeLatitude.value,
                  paramController.fakeLongitude.value), //LatLng(, paramController.fakeLongitude.value),
              initialZoom: 16,
              onMapReady: () {
                // controller.mapController = mapController;
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && mounted) {
                  setState(() {
                    followUser = false;
                  });
                }
              },
              onTap: (tapPosition, point) {
                // Reset the polygons when clicking anywhere on the map

                if (mounted) {
                  setState(() {
                    _hoverGons = null;
                    _prevHitValues = null;
                  });
                }
              },
            ),
            children: [
              Text("${paramController.fakeLatitude.value}"),
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': dotenv.env['MAPBOX_ACCESS_TOKEN']!,
                  'id': 'mapbox.satellite',
                },
              ),
              MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click,
                onHover: (_) {
                  final hitValues = _hitNotifier.value?.hitValues.toList();
                  if (hitValues == null) {
                    return;
                  }

                  if (listEquals(hitValues, _prevHitValues)) return;
                  _prevHitValues = hitValues;

                  var polygons = Map.fromEntries(drawnPolygons.map((e) => MapEntry(e.hitValue, e)));

                  final hoverLines = hitValues.map((v) {
                    final original = polygons[v]!;

                    return Polygon<HitValue>(
                      points: original.points,
                      holePointsList: original.holePointsList,
                      color: Colors.transparent,
                      borderStrokeWidth: 15,
                      borderColor: Colors.green,
                      disableHolesBorder: original.disableHolesBorder,
                    );
                  }).toList();
                  if (mounted) {
                    setState(() => _hoverGons = hoverLines);
                  }
                },
                onExit: (_) {
                  if (mounted) {
                    setState(() {
                      _hoverGons = null;
                      _prevHitValues = null;
                    });
                  }
                },
                child: GestureDetector(
                  // onTap: () => _openTouchedGonsModal(
                  //   'Tapped',
                  //   _hitNotifier.value!.hitValues,
                  //   _hitNotifier.value!.coordinate,
                  // ),
                  child: Stack(children: [
                    PolylineLayer(
                      hitNotifier: _hitNotifier,
                      polylines: [...drawnPolylines],
                      simplificationTolerance: 0,
                    ),
                    PolygonLayer(
                      hitNotifier: _hitNotifier,
                      simplificationTolerance: 0,
                      polygons: [...drawnPolygons, ...?_hoverGons],
                    ),
                    MarkerLayer(
                      markers: getMarkerList(),
                      rotate: true,
                    ),
                  ]),
                ),
              )
            ]),
      ),
    );
  }

  Widget managementButtons() {
    return Container(
        decoration: BoxDecoration(
          color: lightGrey.withOpacity(0.9),
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Column(children: [
          verticalSpaceSmall,
          ElevatedButton(
            onPressed: () {
              updateConnectedStatus(ConnectedStatus.DISCONNECTED);
              stopSendingBSM();
              connectToMqttBroker();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              backgroundColor: connectedButtonColor, // <-- Button color
              foregroundColor: Colors.black, // <-- Splash color
              shadowColor: Colors.black,
            ),
            // child: Icon(Icons.menu, color: Colors.white),
            child: const Icon(Icons.connect_without_contact_rounded, color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              followUser = true;
              _mapController.moveAndRotate(
                  getUserLocation(), _mapController.camera.zoom, _mapController.camera.rotation);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              backgroundColor: followUser ? Colors.green : Colors.blue, // <-- Button color
              foregroundColor: Colors.black, // <-- Splash color
              shadowColor: Colors.black,
            ),
            // child: Icon(Icons.menu, color: Colors.white),
            child: const Icon(Icons.directions_car, color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              addToAppLog("Upload Log Files");
              uploadAllLogs();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.green,
              foregroundColor: Colors.black, // <-- Splash color
              shadowColor: Colors.black,
            ),
            // child: Icon(Icons.menu, color: Colors.white),
            child: const Icon(Icons.upload, color: Colors.white),
          ),
          verticalSpaceSmall,
        ]));
  }

  Widget sirenButton() {
    return Obx(() => GestureDetector(
          onTap: () {
            if (configController.isSirenOn.value) {
              configController.stopSiren();
            } else {
              configController.startSiren();
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: configController.isSirenOn.value ? Colors.red : mediumGrey,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                configController.isSirenOn.value
                    ? configController.images[configController.sirenPhotoIndex.value]
                    : "assets/images/Siren/siren_bw.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }

  Widget busWarningButton() {
    return Obx(() => GestureDetector(
          onTap: () {
            configController.isBusWarningOn.value = !configController.isBusWarningOn.value;
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: configController.isBusWarningOn.value ? Colors.orange : mediumGrey,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                configController.isBusWarningOn.value
                    ? "assets/images/Bus/bus_warning.png"
                    : "assets/images/Bus/bus_warning_bw.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }

  Widget speedMarker() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                mediumGrey.withOpacity(0.9),
                lightGrey.withOpacity(0.9),
                mediumGrey.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(
                children: [
                  // Outline layers
                  Text(
                    ((currentPosition?.speed ?? 0) * 2.23694).toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 52.0,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3.0
                        ..color = primaryColor.withOpacity(0.5), // Outline color
                    ),
                  ),
                  // Main text
                  Text(
                    ((currentPosition?.speed ?? 0) * 2.23694).toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 52.0,
                      color: Colors.black, // Fill color
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  // Outline layers
                  Text(
                    "MPH",
                    style: TextStyle(
                      fontSize: 32.0,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2.0
                        ..color = primaryColor.withOpacity(0.5), // Outline color
                    ),
                  ),
                  // Main text
                  const Text(
                    "MPH",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black, // Fill color
                    ),
                  ),
                ],
              ),
            ]),
          )),
    );
  }

  Widget timsDisplay() {
    List<Widget> timIcons = [];
    for (ItisCode code in showTims) {
      Widget icon = code.image != null
          ? Image(
              image: code.image!,
            )
          : Text(
              code.description,
              style: const TextStyle(fontSize: 16.0),
            );
      timIcons.add(icon);
    }
    if (timIcons.length <= 4) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: timIcons.map((icon) {
          // Dynamically calculate the size based on the number of icons
          double iconSize = timIcons.length <= 1 ? 140 : (timIcons.length <= 2 ? 100 : 70);
          return SizedBox(
            width: iconSize,
            height: iconSize,
            child: icon,
          );
        }).toList(),
      );
    } else {
      // Create a grid with 2 rows
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4, // 2 columns
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: timIcons,
      );
    }
  }

  void _openTouchedGonsModal(
    String eventType,
    List<HitValue> tappedLines,
    LatLng coords,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TIM Message',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Text(
            //   '$eventType at point: (${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)})',
            // ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final tappedLineData = tappedLines[index];
                  TravelerDataFrame frame = tappedLineData.frame;
                  return FutureBuilder<ItisCode>(
                      future: timManager.getItisRepresentationForDataFrame(tappedLineData.frame),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Show a loading indicator while waiting for the async call
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text("Loading..."),
                          );
                        } else if (snapshot.hasError) {
                          // Handle any errors that occurred during the async call
                          return ListTile(
                            leading: const Icon(Icons.error),
                            title: const Text("Error loading data"),
                            subtitle: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.hasData) {
                          // Show the actual data once it has been fetched
                          final ItisCode code = snapshot.data!;
                          return ListTile(
                            leading: index == 0
                                ? code.image != null
                                    ? Image(image: code.image!)
                                    : Text(code.description, style: const TextStyle(fontSize: 16.0))
                                : index == tappedLines.length - 1
                                    ? const Icon(Icons.vertical_align_bottom)
                                    : const SizedBox.shrink(),
                            title: const Text("TIM Message"),
                            subtitle: Text(
                                "Description: ${code.description}\nStart Time: ${timManager.getTimStartTime(frame)}\n End Time: ${timManager.getTimEndTime(frame)}"),
                            dense: false,
                          );
                        }
                        // Default case: show nothing if there’s no data
                        return const SizedBox.shrink();
                      });
                },
                itemCount: tappedLines.length,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        _hoverGons = null;
                        _prevHitValues = null;
                      });
                    }
                  },
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
