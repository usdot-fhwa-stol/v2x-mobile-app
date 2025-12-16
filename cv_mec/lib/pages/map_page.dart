import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:core';
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
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
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
import 'package:bluetooth_classic/models/device.dart';
import 'package:cv_mec/controllers/obd_controller.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/api_responses/path_response/vehicle_path.dart';
import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/models/geometry_direction.dart';
import 'package:cv_mec/models/icon_manager.dart';
import 'package:cv_mec/models/itis/itis_converter.dart';
import 'package:cv_mec/models/itis/itis_sequence.dart';
import 'package:cv_mec/models/data_frame_geometry.dart';
import 'package:cv_mec/models/geo_map.dart';
import 'package:cv_mec/models/leidos_date_extraction.dart';
import 'package:cv_mec/models/message_builders/bsm_message_builder.dart';
import 'package:cv_mec/models/message_builders/psm_message_builder.dart';
import 'package:cv_mec/models/message_managers/map_manager.dart';
import 'package:cv_mec/models/message_managers/received_message_manager.dart';
import 'package:cv_mec/models/mqtt/etx_mqtt_agent.dart';
import 'package:cv_mec/models/mqtt/iss_mqtt_agent.dart';
import 'package:cv_mec/models/mqtt/mqtt_agent_manager.dart';
import 'package:cv_mec/models/mqtt/pc5_mqtt_agent.dart';
import 'package:cv_mec/models/msg_types.dart';
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
import 'package:cv_mec/models/vehicle.dart';
import 'package:cv_mec/services/gpsd_service.dart';
import 'package:cv_mec/services/path_service.dart';
import 'package:cv_mec/services/remote_gps.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/secure_storage.dart';
import 'package:cv_mec/services/vehicle_notification_manager.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/arc_painter.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/appbar.dart';
import 'package:cv_mec/views/bluetooth_dialog.dart';
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
import 'package:iss_scms/iss_scms.dart';
import 'package:iss_scms/models/psid.dart';
import 'package:iss_scms/models/validate_status.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:toastification/toastification.dart';

enum ConnectedStatus { UNKNOWN, DISCONNECTED, CONNECTED, PARTIAL }

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
  
  RemoteGPSService gpsService = Get.find<RemoteGPSService>();
  GPSDService gpsdService = Get.find<GPSDService>();
  PathService pathService = Get.find<PathService>();

  Timing timingService = Get.find<Timing>();

  LocationService locationService = Get.find<LocationService>();
  SettingsController settingsController = Get.find<SettingsController>();
  S3Service awsService = Get.find<S3Service>();
  ConfigurationController configController = Get.find<ConfigurationController>();
  IssScms scms = Get.find<IssScms>();

  TimManager timManager = TimManager();
  MapManager mapManager = MapManager();
  SpatManager spatManager = SpatManager();
  ReceivedMessageManager messageManager = ReceivedMessageManager();

  SecureStorage secureStorage = SecureStorage();

  Uuid uuid = const Uuid();

  Position? currentPosition;
  late String deviceID;

  Timer? sendMessageTimer;
  late BsmMessageBuilder bsmBuilder;
  late PsmMessageBuilder psmBuilder;

  Timer? uploadTimer;

  Color connectedButtonColor = Colors.red;
  StreamSubscription<Position>? positionStream;

  List<ItisSequence> showTims = [];
  List<Polygon<HitValue>> drawnPolygons = [];
  List<Polyline<PolyLineHitValue>> drawnPolylines = [];
  List<Marker> lightMarkerList = [];
  List<Marker> drawnMarkers = [];

  bool followUser = true;

  late DataQueue recDataQueue;
  late DataQueue pubDataQueue;
  late DataQueue appDataQueue;
  late DataQueue timDataQueue;

  final LayerHitNotifier<HitValue> _hitNotifier = ValueNotifier(null);
  final LayerHitNotifier<PolyLineHitValue> _polyLineHitNotifier = ValueNotifier(null);
  List<HitValue>? _prevHitValues;
  List<Polygon<HitValue>>? _hoverGons;

  late FlutterTts flutterTts;

  final MqttAgentManager mqttAgents = MqttAgentManager();

  final Map<MovementPhaseState, Image> lightStateMap = {
    MovementPhaseState.UNAVAILABLE: Image.asset("assets/images/Lights/traffic-light-icon-unknown.png"),
    MovementPhaseState.DARK: Image.asset("assets/images/Lights/traffic-light-icon-unknown.png"),
    MovementPhaseState.STOP_THEN_PROCEED: Image.asset("assets/images/Lights/traffic-light-icon-red-flashing.png"),
    MovementPhaseState.STOP_AND_REMAIN: Image.asset("assets/images/Lights/traffic-light-icon-red.png"),
    MovementPhaseState.PRE_MOVEMENT: Image.asset("assets/images/Lights/traffic-light-yellow-red.png"),
    MovementPhaseState.PERMISSIVE_MOVEMENT_ALLOWED: Image.asset("assets/images/Lights/traffic-light-icon-green.png"),
    MovementPhaseState.PROTECTED_MOVEMENT_ALLOWED: Image.asset("assets/images/Lights/traffic-light-icon-green.png"),
    MovementPhaseState.PROTECTED_CLEARANCE: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png"),
    MovementPhaseState.PERMISSIVE_CLEARANCE: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png"),
    MovementPhaseState.CAUTION_CONFLICTING_TRAFFIC: Image.asset("assets/images/Lights/traffic-light-icon-yellow.png")
  };

  final Logger _logger = Logger();

  late Image currentLightState;
  late String nextLightText = "";

  bool debugMode = false;
  bool showLoadingIcon = true;
  bool showLightText = true;
  bool scmsActive = false;

  bool showVehicleStats = false;
  RxBool obdConnecting = false.obs;

  OBDController obdController = Get.find<OBDController>();

  DateTime lastRedrawTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    deviceID = uuid.v4();

    _mapController = MapController();
    timingService.startAllUpdates();

    bsmBuilder = BsmMessageBuilder();
    psmBuilder = PsmMessageBuilder();

    if (mounted) {
      setState(() {
        showLoadingIcon = true;
      });
    }

    updateConnectedStatus(ConnectedStatus.PARTIAL);

    currentLightState = lightStateMap[MovementPhaseState.UNAVAILABLE]!;

    if (debugMode) {

      TravelerInformation plugfest5 = asnService.decodeTim(TestData.plugfestWeatherPolygonTim);
      timManager.addOrUpdate(plugfest5,TestData.plugfestWeatherPolygonTim);

      TravelerInformation plugfest6 = asnService.decodeTim(TestData.plugfestWorkZoneTim);
      timManager.addOrUpdate(plugfest6,TestData.plugfestWorkZoneTim);

    } else if (settingsController.demoMode.value) {
      TravelerInformation weatherTimDemo = asnService.decodeTim(TestData.tfhrcWeatherTIMDemo);
      timManager.addOrUpdate(weatherTimDemo, TestData.tfhrcWeatherTIMDemo);

      TravelerInformation vslTimDemo = asnService.decodeTim(TestData.tfhrcVSLTIMDemo);
      timManager.addOrUpdate(vslTimDemo, TestData.tfhrcWeatherTIMDemo);
    }

    flutterTts = FlutterTts();


    Future.delayed(Duration.zero, () async {
      int loggingEnabled = await enableLogging();
      if (loggingEnabled != 0) {
        return;
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

      if(settingsController.enableIssScmsSigning.value){
        scmsActive = await scms.activateScms(settingsController.issScmsToken.value);
        if(!scmsActive){
          showError("Unable to Activate SCMS Signing");
        }
      }else{
        scmsActive = false;
      }

      await createGPSStream();
      await connectMqttAgents();

      

      
      startSendingBSM();

      
      if (Platform.isAndroid || Platform.isIOS) {
        WakelockPlus.enable();
      }

      updateConnectedStatus(ConnectedStatus.CONNECTED);
      setState(() {
        showLoadingIcon = false;
      });

      
    });

    updateGraphics();
    

    obdController.checkRootStatus();
  }

  // Helper function to disconnect and reconnect all mqtt agents
  Future<void> connectMqttAgents() async {
    setState(() {
      showLoadingIcon = true;
    });
    mqttAgents.disconnectAll();
    mqttAgents.clearAgents();

    if(settingsController.enableEtxMqtt.value){
      addToAppLog("Adding ETX MQTT Agent");
      mqttAgents.addAgent(EtxMqttAgent(processIncomingMessage));

    }

    if(settingsController.enablePC5.value){
      addToAppLog("Adding PC5 MQTT Agent");
      mqttAgents.addAgent(Pc5MqttAgent(processIncomingMessage));
    }
    
    if(settingsController.enableIssMqtt.value){
      addToAppLog("Adding ISS MQTT Agent");
      mqttAgents.addAgent(IssMqttAgent(processIncomingMessage));
    }
    
    mqttAgents.setPosition(currentPosition);
    var success = await mqttAgents.connectAll();
    if(success != 0){
      showError("Unable to connect all configured MQTT Agents");
    }
    success = await mqttAgents.subscribeAll();
    if(success != 0){
      showError("Unable to Subscribe all configured MQTT Agents");
    }
    setState(() {
      showLoadingIcon = false;
    });
  }

  Future<void> createGPSStream() async{
    Stream<Position> stream;
    if (debugMode) {
      stream = fakePosition(TestData.plugfestFakePosition);
    } else if (settingsController.gpsType.value == GPSType.path) {
      VehiclePath? path = pathService.getPathByName(settingsController.pathToFollow.value);
      print("path to follow: ${settingsController.pathToFollow.value}");
      if(path!=null){
        stream = pathService.followPath(path);
      }else{
        stream = locationService.locationStream;
      }
    } else if (settingsController.gpsType.value == GPSType.cradle) {
      stream = gpsService.positionStream(interval: const Duration(milliseconds: 500));
    } else if (settingsController.gpsType.value == GPSType.obu) {
      gpsdService.connectToGPSD(settingsController.obuIP.value, 2947);
      stream = gpsdService.locationStream.stream;
    } else {
      stream = locationService.locationStream;
    }

    stream.listen(updatePosition);
    if(currentPosition == null){
      try{
        await stream.first;
      }on StateError catch(e){
        // Catch exception in case stream has already been listened to.
        _logger.w("caught error with stream.first called on existing stream");
      }
      
    }     
  }
  

  void updateGraphics(){
    if (mounted) {
      if(DateTime.now().difference(lastRedrawTime).inMilliseconds > 50){ //DateTime.now used since timing service accuracy not required, and may not be initialized yet.
        setState(() {
          drawnPolygons = getPolygons();
          drawnPolylines = getPolylines();
          drawnMarkers = getMarkerList();
          lastRedrawTime = DateTime.now();
        });
      }
    }
  }

  @override
  void dispose() {
    configController.stopSiren();
    configController.isBusWarningOn.value = false;
    configController.isIceCreamSongOn.value = false;
    obdController.disconnect();
    super.dispose();
  }

  void fakeSpatMessages(List<String> fakeSpats) {
    int spatSimStartTime = timingService.getTime().toUtc().millisecondsSinceEpoch;
    int yearStartMs = DateTime(timingService.getTime().year, 1, 1).millisecondsSinceEpoch;

    int revision = 0;

    int minEndTime = 0;
    int maxEndTime = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      DateTime now = timingService.getTime().toUtc().subtract(DateTime.now().timeZoneOffset);
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

  

  Stream<Position> fakePosition(List<List<double>> fakePosition) {
    return Stream<Position>.periodic(const Duration(milliseconds: 500), (count) {
      List<List<double>> route = fakePosition.reversed.toList();
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

  void createDataQueues(){
    DateTime logTime = timingService.getTime();

    recDataQueue = DataQueue("MQTT_SUB_LOG_${logTime.millisecondsSinceEpoch}.csv");
    pubDataQueue = DataQueue("MQTT_PUB_LOG_${logTime.millisecondsSinceEpoch}.csv");
    appDataQueue = DataQueue("APP_LOG_${logTime.millisecondsSinceEpoch}.log");
    timDataQueue = DataQueue("TIM_LOG_${logTime.millisecondsSinceEpoch}.csv");
    String subHeader =
        "topic,message_type,receive_time_ms,send_time_ms,generation_time_ms,send_rec_delta_time_ms,gen_rec_delta_time_ms,longitude,latitude,broker,msg_bytes,msg_source,signature\n";
    String pubHeader = "topic,send_time_ms,longitude,latitude,broker,msg_bytes,signed\n";
    String timHeader = "action,time,longitude,latitude,heading,asn1\n";

    recDataQueue.addItem(subHeader);
    pubDataQueue.addItem(pubHeader);
    timDataQueue.addItem(timHeader);
  }

  Future<int> enableLogging() async {
    
    createDataQueues();
    uploadTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      rotateAndUploadLogs();
    });

    return 0;
  }

  void processIncomingMessage(String? broker, String topic, List<int> bytes, DateTime recTime, DateTime? sendTime, String source) async {
    String hex = ASNService.bytesToHex(bytes);
    MsgType msgType = asnService.determineHexMessageType(hex);
    ValidateStatus validity;
    if(Platform.isAndroid || Platform.isIOS){
      validity= await scms.validate(bytes);
    }else{
      validity = ValidateStatus.FAILURE;
    }

    switch (msgType) {
      case MsgType.BSM:
        addToAppLog("Identified Message as BSM");
        processNewBsm(broker, topic, hex, recTime, sendTime, source, validity);
        break;
      case MsgType.PSM:
        addToAppLog("Identified Message as PSM");
        processNewPsm(broker, topic, hex, recTime, sendTime, source, validity);
        break;
      case MsgType.SPAT:
        addToAppLog("Identified Message as SPaT");
        processNewSpat(broker, topic, hex, recTime, sendTime, source, validity);
        break;
      case MsgType.MAP:
        addToAppLog("Identified Message as MAP");
        processNewMap(broker, topic, hex, recTime, sendTime, source, validity);
        break;
      case MsgType.TIM:
        addToAppLog("Identified Message as TIM");
        processNewTim(broker, topic, hex, recTime, sendTime, source, validity);
        break;
      case MsgType.SDSM:
        addToAppLog("Identified Message as SDSM");
        processNewSdsm(broker, topic, hex, recTime, sendTime, source, validity);
        break;
      default:
        addToAppLog("Unable to Identify Message Type: $msgType");
    }
  }

  void processNewBsm(String? broker, String topic, String hex, DateTime recTime, DateTime? sendTime, String source, ValidateStatus validity) {
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
    addToReceiveLog(broker, topic, "BSM", recTime, sendTime, bsmTime, trimmedHex, source, validity);
  }

  void processNewPsm(String? broker, String topic, String hex, DateTime recTime, DateTime? sendTime, String source, ValidateStatus validity) {
    String trimmedHex = asnService.trimMessageHeaders(hex, asnService.PSM_START_FLAG)!;
    PersonalSafetyMessage psm = asnService.decodePsm(trimmedHex);

    LatLng position = LatLng(psm.position.lat.getDecimalLatitude(), psm.position.long.getDecimalLongitude());
    String pedestrianID = ASNService.bytesToHex(psm.id.temporaryID);

    DateTime psmTime = psm.secMark.getDateTime(recTime);

    ReceivedMsg msg = ReceivedPsm(pedestrianID, psmTime, position, psm.basicType, psm.eventResponderType);
    messageManager.addOrUpdate(msg);
    addToReceiveLog(broker, topic, "PSM", recTime, sendTime, psmTime, trimmedHex, source, validity);
  }

  void processNewSpat(String? broker, String topic, String hex, DateTime recTime, DateTime? sendTime, String source, ValidateStatus validity) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.SPAT_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    Spat spat = asnService.decodeSpat(trimmedHex);

    spatManager.addOrUpdate(spat);

    updateGraphics();
    DateTime? spatGenTime;
    if (spat.intersections.intersectionStateList.isNotEmpty) {
      spatGenTime = spat.intersections.intersectionStateList.first.getUtcTime();
    }

    addToReceiveLog(broker, topic, "SPAT", recTime, sendTime, spatGenTime, trimmedHex, source, validity);
  }

  void processNewMap(String? broker,String topic, String hex, DateTime recTime, DateTime? sendTime, String source, ValidateStatus validity) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.MAP_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    MapData map = asnService.decodeMap(trimmedHex);

    mapManager.addOrUpdate(map);

    updateGraphics();

    addToReceiveLog(broker, topic, "MAP", recTime, sendTime, LeidosDateExtraction.extractDateFromMap(map), trimmedHex, source, validity);
  }

  void processNewTim(String? broker, String topic, String hex, DateTime recTime, DateTime? sendTime, String source, ValidateStatus validity) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.TIM_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    TravelerInformation tim = asnService.decodeTim(trimmedHex);
    timManager.addOrUpdate(tim, hex);
    updateGraphics();
    DateTime? generationTime = LeidosDateExtraction.extractDateFromTim(tim);
    Future.delayed(const Duration(milliseconds: 0), () async {
      String messageType = "TIM";
      if (tim.dataFrames.travelerDataFrameList.isNotEmpty) {
        ItisSequence sequence = await timManager.getItisRepresentationForDataFrame(tim.dataFrames.travelerDataFrameList.first);
        messageType = "TIM ${sequence.description}";
      }
      addToReceiveLog(broker, topic, messageType, recTime, sendTime, generationTime, trimmedHex, source, validity);
    });
  }

  void processNewSdsm(String? broker, String topic, String hex, DateTime recTime, DateTime? sendTime, String source, ValidateStatus validity) {
    String trimmedHex = asnService.trimMessageHeaders(
        hex, asnService.SDSM_START_FLAG)!; // Msg Type has already been identified, start flag guaranteed
    SensorDataSharingMessage sdsm = asnService.decodeSdsm(trimmedHex);
    sdsm.sDSMTimeStamp.year ??= DYear(recTime.year);
    sdsm.sDSMTimeStamp.month ??= DMonth(recTime.month);
    sdsm.sDSMTimeStamp.day ??= DDay(recTime.day);
    sdsm.sDSMTimeStamp.hour ??= DHour(recTime.hour);
    sdsm.sDSMTimeStamp.minute ??= DMinute(recTime.minute);
    sdsm.sDSMTimeStamp.second ??= DSecond(recTime.second);

    LatLng refPos = LatLng(sdsm.refPos.lat.getDecimalLatitude(), sdsm.refPos.long.getDecimalLongitude());


    for (DetectedObjectData object in sdsm.objects.objects) {
      String id = "${sdsm.sourceID}_${object.detObjCommon.objectID.objectID}";
      DateTime objectTime =
          recTime.add(Duration(milliseconds: object.detObjCommon.measurementTime.mesurementTimeOffset));

      LatLng shiftedPosition = geometryService.shiftLatLngByMeters(refPos, object.detObjCommon.pos.offsetX.getDistanceInMeters(),
          object.detObjCommon.pos.offsetY.getDistanceInMeters());
      messageManager.addOrUpdate(ReceivedSdsm(id, objectTime, shiftedPosition, object.detObjCommon.objType));
    }

    addToReceiveLog(broker, topic, "SDSM", recTime, sendTime, sdsm.sDSMTimeStamp.getAsDateTime(), trimmedHex, source, validity);
  }

  void addToReceiveLog(String? broker, String topic, String msgType, DateTime recTime, DateTime? sendTime, DateTime? generationTime,
      String hex, String source, ValidateStatus validity) async {
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
        "$topic, ${msgType.toString().split('.').last}, ${recTime.millisecondsSinceEpoch},$logSendTime,$messageGenerationTime,$delta,$generationDelta,$longitude,$latitude,$broker,$hex,$source,${validity.name}\n";
    recDataQueue.addItem(record);
  }

  void showError(String message) {
    addToAppLog("ERROR: $message");
    _logger.e("ERROR: $message");
  }

  void addToAppLog(String message) {
    _logger.i("APPLOG: $message");
    appDataQueue.addItem("$message\n");
  }

  void startSendingBSM() {
    // Stop any previous timer
    sendMessageTimer?.cancel();

    int broadcastIntervalMilliseconds = (1000 / settingsController.broadcastRate.value).toInt();

    sendMessageTimer = Timer.periodic(Duration(milliseconds: broadcastIntervalMilliseconds), (timer) {
      sendMessage();
      if (!isConnected()) {
        stopSendingBSM();
        onMqttDisconnect();
      }
    });
  }

  List<int>? lastSignedMessage = null;

  void sendMessage() async {
    if (currentPosition == null) {
      addToAppLog("Cannot Send BSM. Location is Null");
      updateConnectedStatus(ConnectedStatus.PARTIAL);
      return;
    }

    DateTime sendTime = timingService.getTime();
    String hex = "";
    int psid = PSID.BSM.code;
    MsgType messageType = MsgType.BSM;


    // Switch to PSM messages depending on config settings.
    if (configController.isVehicleConfig.value) {
      bsmBuilder.setPosition(currentPosition!);
      bsmBuilder.incrementMsgCnt();
      bsmBuilder.setTime(sendTime);

      bsmBuilder.setVehicleClass(
          BasicVehicleClass(VehicleType.toVehicleClass(configController.selectedVehicle.value.classification).code));

      LightbarInUse lightStatus = LightbarInUse.unavailable;
      SirenInUse sirenUse = SirenInUse.unavailable;

      if (configController.isBusWarningOn.value || configController.isIceCreamSongOn.value) {
        lightStatus = LightbarInUse.inUse;
      }

      if (configController.isSirenOn.value) {
        sirenUse = SirenInUse.inUse;
      }

      bsmBuilder.setEmergencyVehicleLights(lightStatus, sirenUse);
      psid = PSID.BSM.code;
      messageType = MsgType.BSM;
      hex = bsmBuilder.build();
    } else {
      psmBuilder.setPosition(currentPosition!);
      psmBuilder.incrementMsgCnt();
      psmBuilder.setTime(sendTime);
      psmBuilder.setPersonalDeviceUserType(configController.selectedPedestrian);
      if (configController.selectedPedestrian == PersonalDeviceUserType.APUBLICSAFETYWORKER) {
        psmBuilder.setPublicSafetyWorkerType(configController.selectedPublicSafetyWorker);
      }
      psid = PSID.PSM.code;
      messageType = MsgType.PSM;
      hex = psmBuilder.build();
    }

    bool signed = false;
    if (hex != "") {
      List<int> messageBytes = ASNService.hexToBytes(hex);
      
      if(scmsActive){
        List<int>? signedMessageBytes = await scms.sign(psid, messageBytes);
        if(signedMessageBytes != null && signedMessageBytes.isNotEmpty){
          messageBytes = signedMessageBytes;
          signed = true;
        }else{
          showError("Result of Message Signing was Null or Empty");
        }
      }
      
      mqttAgents.sendMessage(messageBytes, messageType, sendTime, pubDataQueue, signed);
      int connectionCount = mqttAgents.getConnectionCount();
      if( connectionCount == mqttAgents.agents.length){
        updateConnectedStatus(ConnectedStatus.CONNECTED);
      }else if(connectionCount > 0){
        updateConnectedStatus(ConnectedStatus.PARTIAL);
      }else{
        updateConnectedStatus(ConnectedStatus.DISCONNECTED);
      }
    }
  }

  void stopSendingBSM() {
    sendMessageTimer?.cancel();
  }

  DateTime prevNtp = DateTime.now();
  DateTime prevKronos = DateTime.now();
  DateTime prevLocal = DateTime.now();
  DateTime prevSystemTime = DateTime.now();

  Future<void> updatePosition(Position position) async {
    currentPosition = position;
    mqttAgents.setPosition(currentPosition);

    DateTime now = DateTime.now();

    DateTime ntp = timingService.getNtpTime();
    DateTime kronos = timingService.getTime();

    prevNtp = ntp;
    prevKronos = kronos;
    prevLocal = now;

    updateGraphics();
    updateTimeToChange();

    if (followUser) {
      _mapController.moveAndRotate(getUserLocation(), _mapController.camera.zoom, _mapController.camera.rotation);
    }


    if(!configController.isVehicleConfig.value && configController.selectedPedestrian != PersonalDeviceUserType.APEDALCYCLIST) {
      return; // Skip all of the TIM logic if we are a not a vehicle or a cyclist. 
    }

    List<TravelerDataFrame> newActiveTims = [];
    List<ReceivedMsg> newReceivedMessages = messageManager.getNewReceivedMessages(
        LatLng(currentPosition!.latitude, currentPosition!.longitude), currentPosition!.heading);
    
    List<ItisSequence> receivedMessageItisSequence = messageManager.convertToItisSequence(newReceivedMessages);

    secureStorage.getNotificationsEnabled().then((enabled) {
      if (enabled) {
        timManager.getItisRepresentationForDataFrames(newActiveTims).then((sequences) async {
          for (ItisSequence sequence in sequences) {
            await VehicleNotificationManager.notifyVehicleFromItisSequence(sequence);
          }
        });

        for (ItisSequence sequence in receivedMessageItisSequence) {
          VehicleNotificationManager.notifyVehicleFromItisSequence(sequence);
        }
      }
    });

    secureStorage.getReadMessages().then((enabled) {
      if (enabled) {
        timManager.getItisRepresentationForDataFrames(newActiveTims).then((sequences) async {
          for (ItisSequence sequence in sequences) {
            String message = ItisConverter.getItisListAsString(sequence.associatedCodes);
            await flutterTts.speak(message);
          }

          for (ItisSequence sequence in receivedMessageItisSequence) {
            await flutterTts.speak(sequence.description);
          }
        });
      }
    });

    List<TravelerDataFrame> frames = [];

    // if speed is less than 1 meter / second (~2.2 mph)
    if (position.speed < 1) {
      newActiveTims = timManager.getNewActiveTims(
          position.longitude, position.latitude, position.heading, true, settingsController.demoMode.value || debugMode);

      frames = timManager.getTimsToShow(
          position.longitude, position.latitude, position.heading, true, settingsController.demoMode.value || debugMode);
    } else {
      newActiveTims = timManager.getNewActiveTims(
          position.longitude, position.latitude, position.heading, false, settingsController.demoMode.value || debugMode);

      frames = timManager.getTimsToShow(
          position.longitude, position.latitude, position.heading, false, settingsController.demoMode.value || debugMode);
    }

    List<ItisSequence> sequences = await timManager.getItisRepresentationForDataFrames(frames);
    List<ItisSequence> msgs = messageManager.convertToItisSequence(
        messageManager.getActiveMessages(LatLng(position.latitude, position.longitude), position.heading));

    List<String> hex = timManager.getUniqueAsnFromDataFrames(frames);
    for (String str in hex) {
      addToTimLog("ALERT", str);
    }

    sequences.addAll(msgs);

    Map<ImageProvider, ItisSequence> uniqueSequences = <ImageProvider, ItisSequence>{};

    // Tims with Identical Images are considerd the same. All images are pulled from image map so object comparison is sufficient.
    for(ItisSequence sequence in sequences){
      if(!uniqueSequences.containsKey(sequence.image)){
        uniqueSequences[sequence.image] = sequence;
      }
    }

    if (mounted) {
      setState(() {
        showTims = uniqueSequences.values.toList();
      });
    }
  }

  void onMqttDisconnect() {
    showError("Lost Connection to All MQTT Brokers");
    updateConnectedStatus(ConnectedStatus.DISCONNECTED);
    stopSendingBSM();
    mqttAgents.clearAgents();
    if (Platform.isAndroid || Platform.isIOS) {
      WakelockPlus.disable();
    }
    uploadTimer?.cancel();
  }

  bool isConnected() {
    return mqttAgents.getConnectionCount() > 0;
  }

  LatLng getUserLocation() {
    if (currentPosition != null) {
      return LatLng(currentPosition!.latitude, currentPosition!.longitude);
    } else {
      return LatLng(paramController.registrationLatitude.value, paramController.registrationLongitude.value);
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
        } else if (status == ConnectedStatus.PARTIAL) {
          connectedButtonColor = Colors.orange;
        }
      });
    }
  }

  void updateTimeToChange() {
    DateTime now = timingService.getTime();
    LightChangeTime? next;
    Position? pos = currentPosition;
    if (pos != null) {
      List<GeoMap> geoMaps = mapManager.getActiveMaps(pos.longitude, pos.latitude);

      for (GeoMap map in geoMaps) {
        List<int> activeLaneIds = mapManager.getActiveLaneIds(map, pos.longitude, pos.latitude);

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
          }else if (expectedMaxTime == expectedMinTime) {
            text = "Change in:\n $expectedMinTime\n Seconds";
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
      Marker userMarker = Marker(
        point: getUserLocation(),
        width: 60,
        height: 60,
        child: iconBase(getSenderIcon(), Colors.blue[900]!,
            sirensOn: configController.isIceCreamSongOn.value || configController.isSirenOn.value,
            busWarningOn: configController.isBusWarningOn.value),
      );
      markerList.add(userMarker);
      if (_mapController.camera.zoom > 17.5) {
        // Get Maps that the user is near or in
        List<GeoMap> geoMaps = mapManager.getActiveMaps(pos.longitude, pos.latitude);

        for (GeoMap map in geoMaps) {
          // Get SPaT messages associated with the relavent MAP messages
          List<IntersectionState> states =
              spatManager.getActiveSpats(map.intersectionGeometry.id.id.intersectionID, timingService.getTime());

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
    }
    DateTime compTime = timingService.getTime();
    DateTime endTime = compTime.add(const Duration(seconds: 3));
    DateTime startTime = compTime.subtract(const Duration(seconds: 3));

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
    DateTime start = timingService.getTime();
    List<Polyline<PolyLineHitValue>> polylines = [];

    Position? pos = currentPosition;

    if (pos != null) {
      // Get Maps that the user is near or in
      List<GeoMap> geoMaps = mapManager.getActiveMaps(pos.longitude, pos.latitude);
      for (GeoMap map in geoMaps) {
        List<IntersectionState> states =
            spatManager.getActiveSpats(map.intersectionGeometry.id.id.intersectionID, timingService.getTime());
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

    return polygons;
  }

  addToTimLog(String action, String asn1) {
    if (currentPosition != null) {
      timDataQueue.addItem(
          "$action, ${timingService.getTime().millisecondsSinceEpoch}, ${currentPosition!.longitude}, ${currentPosition!.latitude}, ${currentPosition!.heading}, $asn1\n");
    } else {
      timDataQueue.addItem("$action, ${timingService.getTime().millisecondsSinceEpoch}, 0, 0, 0, $asn1\n");
    }
  }

  void rotateAndUploadLogs() {

    addToAppLog("Rotating Log File. Current Time ${timingService.getTime()}");

    String recDataPath = recDataQueue.filePath;
    String pubDataPath = pubDataQueue.filePath;
    String timDataPath = timDataQueue.filePath;
    String appDataPath = appDataQueue.filePath;

    // Assigns new Data Queue objects for each log. Rotate before upload to ensure no data is lost
    createDataQueues();

    addToAppLog("Log Rotation Complete. Current Time ${timingService.getTime()}");


    if (settingsController.deviceID.value.isNotEmpty) {
      awsService.uploadFile(recDataPath, "subscribe/${settingsController.deviceID.value}");
      awsService.uploadFile(pubDataPath, "publish/${settingsController.deviceID.value}");
      awsService.uploadFile(timDataPath, "tim/${settingsController.deviceID.value}");
      awsService.uploadFile(appDataPath, "app/${settingsController.deviceID.value}");
    } else {
      awsService.uploadFile(recDataPath, "subscribe/$deviceID");
      awsService.uploadFile(pubDataPath, "publish/$deviceID");
      awsService.uploadFile(timDataPath, "tim/$deviceID");
      awsService.uploadFile(appDataPath, "app/$deviceID");
    }
  }

  String enumToString(Object o) => o.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final heightBottomDisplay = screenHeight * 0.18;

    const String appTitle = "MAP";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              sendMessageTimer?.cancel();
              positionStream?.cancel();
              uploadTimer?.cancel();
              mqttAgents.disconnectAll();

              Future.delayed(const Duration(milliseconds: 100), () async {
                Get.back();
              });
            }),
        title: const Text(appTitle),
        actions: <Widget>[
          navigationMenu(context),
        ],
      ),
      body: showVehicleStats
          ? Container(
              width: screenWidth,
              height: screenHeight,
              color: Theme.of(context).dialogBackgroundColor,
              child: Stack(alignment: AlignmentDirectional.topStart, children: [
                Positioned(
                  top: 50,
                  child: Obx(() => vehicleStatsPage()),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: vehicleStatsBar(),
                ),
              ]),
            )
          : Stack(alignment: AlignmentDirectional.topStart, children: [
              Center(child: map(context, _mapController)),
              Align(
                  alignment: Alignment.topLeft,
                  child: configController.isVehicleConfig.value ? vehicleStatsBar() : Container()),
              Positioned(
                top: 60,
                right: 0,
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
                              SizedBox(
                                  width: screenWidth * 0.15, height: screenHeight * 0.15, child: currentLightState),
                              Text(nextLightText, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                            ])))
                    : (!showLightText && nextLightText.isNotEmpty)
                        ? SizedBox(width: screenWidth * 0.15, height: screenHeight * 0.15, child: currentLightState)
                        : Container(),
              ),
              Positioned(
                  top: configController.isVehicleConfig.value ? 60 : 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      managementButtons(),
                      verticalSpaceSmall,
                      configController.hasASiren()
                          ? sirenButton()
                          : (configController.isVehicleConfig.value &&
                                  configController.selectedVehicle.value.classification == VehicleType.BUS)
                              ? busWarningButton()
                              : (configController.isVehicleConfig.value &&
                                      configController.selectedVehicle.value.classification ==
                                          VehicleType.ICE_CREAM_TRUCK)
                                  ? iceCreamSongButton()
                                  : Container(width: 60),
                    ]),
                  )),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox(
                    height: screenHeight * 0.2,
                    child: Row(children: [
                      Expanded(
                        child: timsDisplay(heightBottomDisplay, screenWidth),
                      ),
                      configController.isVehicleConfig.value ? speedMarker(heightBottomDisplay) : Container(),
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
        child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(paramController.registrationLatitude.value,
                  paramController.registrationLongitude.value), //LatLng(, paramController.fakeLongitude.value),
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
              Text("${paramController.registrationLatitude.value}"),
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
                  child: Stack(children: [
                    PolylineLayer<PolyLineHitValue>(
                      hitNotifier: _polyLineHitNotifier,
                      polylines: [...drawnPolylines],
                      simplificationTolerance: 0,
                    ),
                    PolygonLayer<HitValue>(
                      hitNotifier: _hitNotifier,
                      simplificationTolerance: 0,
                      polygons: [...drawnPolygons, ...?_hoverGons],
                    ),
                    MarkerLayer(
                      markers: drawnMarkers,
                      rotate: true,
                    ),
                  ]),
                ),
              )
            ]),
      ),
    );
  }

  Widget vehicleStatsBar() {
    return Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mediumGrey, lightGrey, Colors.white],
            stops: const [0, 0.2, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(-1, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            const Text("Vehicle Stats", style: TextStyle(color: Colors.black, fontSize: 20)),
            Expanded(child: Container()),
            IconButton(
                icon: Icon(showVehicleStats ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black),
                onPressed: () {
                  showVehicleStats = !showVehicleStats;
                })
          ]),
        ));
  }

  Widget managementButtons() {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(-1, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(children: [
          verticalSpaceSmall,
          ElevatedButton(
            onPressed: () {
              updateConnectedStatus(ConnectedStatus.DISCONNECTED);
              stopSendingBSM();
              connectMqttAgents();
              startSendingBSM();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              backgroundColor: connectedButtonColor, // <-- Button color
              foregroundColor: Colors.black, // <-- Splash color
              shadowColor: Colors.black,
              elevation: 4,
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
              elevation: 4,
            ),
            // child: Icon(Icons.menu, color: Colors.white),
            child: const Icon(Icons.directions_car, color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              addToAppLog("Upload Log Files");
              rotateAndUploadLogs();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.green,
              foregroundColor: Colors.black, // <-- Splash color
              shadowColor: Colors.black,
              elevation: 4,
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
              color: lightGrey,
              shape: BoxShape.circle,
              border: Border.all(
                color: configController.isSirenOn.value ? Colors.red : mediumGrey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(-1, 3), // changes position of shadow
                ),
              ],
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
              color: lightGrey,
              shape: BoxShape.circle,
              border: Border.all(
                color: configController.isBusWarningOn.value ? Colors.orange : mediumGrey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(-1, 3), // changes position of shadow
                ),
              ],
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

  Widget iceCreamSongButton() {
    return Obx(() => GestureDetector(
          onTap: () async {
            configController.isIceCreamSongOn.value = !configController.isIceCreamSongOn.value;
            if (configController.isIceCreamSongOn.value && settingsController.soundEffectsEnabled.value) {
              configController.playIceCreamSong();
            } else if (!configController.isIceCreamSongOn.value && settingsController.soundEffectsEnabled.value) {
              configController.stopIceCreamSong();
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: lightGrey,
              shape: BoxShape.circle,
              border: Border.all(
                color: configController.isIceCreamSongOn.value ? const Color.fromARGB(255, 255, 94, 148) : mediumGrey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(-1, 3), // changes position of shadow
                ),
              ],
            ),
            child: Icon(
              configController.isIceCreamSongOn.value ? Icons.music_note : Icons.music_off,
              color: configController.isIceCreamSongOn.value ? const Color.fromARGB(255, 255, 94, 148) : mediumGrey,
              size: 30,
            ),
          ),
        ));
  }

  Widget speedMarker(double heightBottomDisplay) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: heightBottomDisplay * (2/3),
        height: heightBottomDisplay,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: lightGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(-1, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: (heightBottomDisplay * (2/3) - 16) * 0.8, // Constrain width
              height: heightBottomDisplay * 0.5, // Constrain height
              child: FittedBox(
                fit: BoxFit.contain,
                child: Stack(
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
              ),
            ),
            SizedBox(
              width: (heightBottomDisplay * (2/3) - 16) * 0.8, // Constrain width
              height: heightBottomDisplay * 0.3, // Constrain height
              child: FittedBox (  
                fit: BoxFit.contain,
                child: Stack(
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
              )
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget timsDisplay(double heightBottomDisplay, double screenWidth) {
    List<Widget> timIcons = [];
    final int maxTimsInRow = (screenWidth / (heightBottomDisplay / 2)).floor();
    for (ItisSequence sequence in showTims) {  
      timIcons.add(Image(image: sequence.image));
    }
    if (timIcons.length <= maxTimsInRow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: timIcons.map((icon) {
          // Dynamically calculate the size based on the number of icons
          double timsDisplayWidth = screenWidth - ((heightBottomDisplay * (2 / 3)) + 20);
          double iconSize = (timsDisplayWidth / timIcons.length) > heightBottomDisplay
              ? heightBottomDisplay
              : timsDisplayWidth / timIcons.length;
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
        crossAxisCount: maxTimsInRow, 
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: timIcons,
      );
    }
  }

  Widget vehicleStatsPage() {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: (obdController.showOBDStats.value) ? obdStatsDisplay() : notConnectedToOBDPage());
  }

  Widget notConnectedToOBDPage() {
    return Container(
      width: screenWidth(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          verticalSpaceMedium,
          Obx(() => obdConnecting.value
              ? const Column(children: [
                  Text("Connecting to OBD-II...", style: TextStyle(fontSize: 24)),
                  verticalSpaceLarge,
                  SpinKitSpinningLines(color: Colors.black, size: 90)
                ])
              : (obdController.isRunningAsRoot && Platform.isLinux) || !Platform.isLinux
                  ? Column(
                      children: [
                        const Text("OBD-II Connection", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        verticalSpaceSmall,
                        const Text(
                          "1. Ensure your OBD-II device is powered on and in range.\n"
                          "2. Pair the OBD-II device with your computer or mobile device via the native Bluetooth menu.\n"
                          "3. Click the button below to connect.",
                        ),
                        verticalSpaceSmall,
                        ElevatedButton(
                          onPressed: () async {
                            if (Platform.isLinux) {
                              await tryToConnectLinux();
                            } else {
                              await tryToConnect();
                            }
                          },
                          child: const Text("Connect to OBD-II"),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        Text(
                            "OBD-II Connection is only available when running as root. Please re-launch the app with root privileges.",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    )),
        ],
      ),
    );
  }

  Future<void> tryToConnect() async {
    bool successfulConnection = false;
    if (!obdController.bluetoothInitialized.value) {
      await obdController.initialize();
    }
    if (configController.selectedVehicle.value.obdIIBluetoothAddress != null) {
      obdConnecting.value = true;
      await obdController.connectToDevice(configController.selectedVehicle.value.obdIIBluetoothAddress!);

      if (obdController.isConnected.value) {
        successfulConnection = true;
        await obdController.startGettingData();
      }
    }
    if (!successfulConnection) {
      Device? device;

      device = await Get.dialog(bluetoothDialog());
      if (device != null) {
        obdConnecting.value = true;
        await obdController.connectToDevice(device.address);
        if (obdController.isConnected.value) {
          await obdController.startGettingData();
        }
      }
    }
    obdConnecting.value = false;
  }

  Future<void> tryToConnectLinux() async {
    bool successfulConnection = false;
    if (configController.selectedVehicle.value.obdIIBluetoothAddress != null) {
      obdConnecting.value = true;
      obdController.setupRfcomm(configController.selectedVehicle.value.obdIIBluetoothAddress!);
      // Wait for /dev/rfcomm0 to exist, then connect
      int maxWaitMs = 10000; // 10 seconds max
      int waited = 0;
      const int pollInterval = 200;
      while (!File('/dev/rfcomm0').existsSync() && waited < maxWaitMs) {
        await Future.delayed(const Duration(milliseconds: pollInterval));
        waited += pollInterval;
      }
      if (File('/dev/rfcomm0').existsSync()) {
        await obdController.connectToPort();
        // await Future.delayed(Duration(seconds: 2));
        // await obdController.startGettingDataLinux();
        // successfulConnection = true;
        int maxWaitMs = 2000; //2 seconds max
        int waited = 0;
        const int pollInterval = 100;
        while (!(obdController.port.isOpen) && waited < maxWaitMs) {
          await Future.delayed(const Duration(milliseconds: pollInterval));
          waited += pollInterval;
        }
        if (obdController.port.isOpen) {
          await obdController.startGettingDataLinux();
          successfulConnection = true;
        } else {
          addToAppLog("Timeout waiting for serial port to open");
        }
      } else {
        // Handle timeout or error
        addToAppLog("Timeout waiting for /dev/rfcomm0 to appear");
      }
    }
    if (!successfulConnection) {
      Device? device;

      device = await Get.dialog(bluetoothDialog());
      if (device != null) {
        obdConnecting.value = true;
        await obdController.setupRfcomm(device.address);
        int maxWaitMs = 10000; // 10 seconds max
        int waited = 0;
        const int pollInterval = 200;
        while (!File('/dev/rfcomm0').existsSync() && waited < maxWaitMs) {
          await Future.delayed(Duration(milliseconds: pollInterval));
          waited += pollInterval;
        }
        if (File('/dev/rfcomm0').existsSync()) {
          await obdController.connectToPort();
          int maxWaitMs = 2000; //2 seconds max
          int waited = 0;
          const int pollInterval = 100;
          while (!(obdController.port.isOpen) && waited < maxWaitMs) {
            await Future.delayed(const Duration(milliseconds: pollInterval));
            waited += pollInterval;
          }
          if (obdController.port.isOpen) {
            await obdController.startGettingDataLinux();
            successfulConnection = true;
          } else {
            addToAppLog("Timeout waiting for serial port to open");
          }
        } else {
          addToAppLog("Timeout waiting for /dev/rfcomm0 to appear");
        }
      }
      obdConnecting.value = false;
    }
    if (!successfulConnection) {
      toastification.show(
        context: Get.context!,
        title: const Text('Failed to connect to OBD-II device'),
        description: const Text(
          'Please ensure your OBD-II device is powered on, in range, and paired then try again.',
        ),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  Widget obdStatsDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        verticalSpaceMedium,
        Obx(() => SizedBox(
              width: screenWidth(context) * 0.8,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                Text(
                  "${obdController.vehicleInfo.value?['Year'] ?? ''} ${obdController.vehicleInfo.value?['Make'] ?? ''} ${obdController.vehicleInfo.value?['Model'] ?? ''}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  obdController.vehicleInfo.value?['Type'] ?? '',
                      style: const TextStyle(fontSize: 16),
                ),
              ]),
            )),
        verticalSpaceMedium,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [speedDisplay(), rpmDisplay()],
          ),
        )
      ],
    );
  }

  Widget speedDisplay() {
    return Container(
        width: 175,
        height: 175,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightGrey, darkGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.black, darkGrey, Colors.white],
                  stops: const [0.9, 0.98, 1],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(children: [
                    const Align(
                      alignment: Alignment(0, 0.8),
                      child: Text("MPH", style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                    Center(
                      child: Obx(() => Text(
                            "${obdController.speed.value.round()}",
                            style: TextStyle(
                              fontSize: 58.0,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3.0
                                ..color = primaryColor, // Outline color
                            ),
                          )),
                    ),
                    Center(
                      child: Obx(() => Text(
                            "${obdController.speed.value.round()}",
                            style: const TextStyle(
                              fontSize: 58.0,
                              color: Colors.white, // Fill color
                            ),
                          )),
                    ),
                    speedArc(),
                  ]),
                ),
              )),
        ));
  }

  Widget rpmDisplay() {
    return Container(
        width: 175,
        height: 175,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightGrey, darkGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.black, darkGrey, Colors.white],
                  stops: const [0.9, 0.98, 1],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(children: [
                    const Align(
                      alignment: Alignment(0, 0.8),
                      child: Text("RPM", style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                    Center(
                      child: Obx(() => Text(
                            "${obdController.rpm.value.round()}",
                            style: TextStyle(
                              fontSize: 40.0,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3.0
                                ..color = primaryColor, // Outline color
                            ),
                          )),
                    ),
                    Center(
                      child: Obx(() => Text(
                            "${obdController.rpm.value.round()}",
                            style: const TextStyle(
                              fontSize: 40.0,
                              color: Colors.white, // Fill color
                            ),
                          )),
                    ),
                    rpmArc(),
                  ]),
                ),
              )),
        ));
  }

  Widget speedArc() {
    return Obx(() {
      final speed = obdController.speed.value;
      final percent = (speed / 200.0).clamp(0.0, 1.0);
      return CustomPaint(
        painter: ArcPainter(percent: percent, color: primaryColor),
        child: Container(
          width: 175,
          height: 175,
        ),
      );
    });
  }

  Widget rpmArc() {
    return Obx(() {
      final rpm = obdController.rpm.value;
      final percent = (rpm / 7000.0).clamp(0.0, 1.0);
      return CustomPaint(
        painter: ArcPainter(percent: percent, color: Colors.red),
        child: Container(
          width: 175,
          height: 175,
        ),
      );
    });
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
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final tappedLineData = tappedLines[index];
                  TravelerDataFrame frame = tappedLineData.frame;
                  return FutureBuilder<ItisSequence>(
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
                          final ItisSequence sequence = snapshot.data!;
                          return ListTile(
                            leading: Image(image: sequence.image),
                            title: const Text("TIM Message"),
                            subtitle: Text(
                                "Description: ${sequence.description}\nStart Time: ${timManager.getTimStartTime(frame)}\n End Time: ${timManager.getTimEndTime(frame)}"),
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
