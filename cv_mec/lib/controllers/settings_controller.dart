import 'package:cv_mec/models/api_responses/secrets/secret_response.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/path_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cv_mec/services/secure_storage.dart';
import 'package:cv_mec/services/shared_pref.dart';

import 'package:flutter/scheduler.dart';
import 'dart:io';

enum GPSType {
  mobile,
  path,
  static,
  obu,
  cradle
}

enum IconSize {
  small,
  medium,
  large,
  extraLarge
}

class SettingsController extends GetxController {
  SettingsController();
  SharedPrefs sharedPrefs = SharedPrefs();
  final SecureStorage secureStorage = SecureStorage();
  late ApiService apiService;
  late PathService pathService;

  // What settings to show
  bool showBaseUri = (dotenv.env['SHOW_BASE_URI'] ?? 'false').toLowerCase() == 'true';
  bool showDeviceID = (dotenv.env['SHOW_DEVICE_ID'] ?? 'false').toLowerCase() == 'true';
  
  bool showMobileGPSType = (dotenv.env['MOBILE_GPS_ALLOWED'] ?? 'false').toLowerCase() == 'true';
  bool showCradleGPSType = (dotenv.env['CRADLE_GPS_ALLOWED'] ?? 'false').toLowerCase() == 'true';
  bool showOBUGPSType = (dotenv.env['OBU_GPS_ALLOWED'] ?? 'false').toLowerCase() == 'true';
  bool showPathGPSType = (dotenv.env['PATH_GPS_ALLOWED'] ?? 'false').toLowerCase() == 'true';
  bool showStaticGPSType = (dotenv.env['STATIC_GPS_ALLOWED'] ?? 'false').toLowerCase() == 'true';
  
  bool showBroadcastRate = (dotenv.env['SHOW_BROADCAST_RATE'] ?? 'false').toLowerCase() == 'true';

  bool showPc5 = (dotenv.env['SHOW_PC5_BROKER'] ?? 'false').toLowerCase() == 'true';
  bool showIss = (dotenv.env['SHOW_ISS_BROKER'] ?? 'false').toLowerCase() == 'true';
  bool showIssBrokerUrl = (dotenv.env['SHOW_ISS_BROKER_URL'] ?? 'false').toLowerCase() == 'true';
  bool showEtx = (dotenv.env['SHOW_ETX_BROKER'] ?? 'false').toLowerCase() == 'true';

  bool showManualRegistration = (dotenv.env['SHOW_MANUAL_REGISTRATION'] ?? 'false').toLowerCase() == 'true';
  bool showVzMode = (dotenv.env['SHOW_VZ_MODE'] ?? 'false').toLowerCase() == 'true';
  bool showDemoMode = (dotenv.env['SHOW_DEMO_MODE'] ?? 'false').toLowerCase() == 'true';
  bool showSigning = (dotenv.env['SHOW_SIGNING'] ?? 'false').toLowerCase() == 'true';
  bool showDisableTUMRetry = (dotenv.env['SHOW_DISABLE_TUM_RETRY'] ?? 'false').toLowerCase() == 'true';

  bool showTollingSettings = (dotenv.env['SHOW_TOLLING_SETTINGS'] ?? 'false').toLowerCase() == 'true';
  bool showTimsSettings = (dotenv.env['SHOW_TIMS_SETTINGS'] ?? 'false').toLowerCase() == 'true';

  Rx<bool> darkModeState = Get.isDarkMode.obs;
  Rx<bool> developerMode = false.obs;
  Rx<bool> soundEffectsEnabled = true.obs;
  Rx<bool> tollingEnabled = true.obs;
  Rx<bool> showTims = true.obs;

  RxString username = dotenv.env['USERNAME']!.obs;
  RxString password = dotenv.env['PASSWORD']!.obs;
  RxString baseUri = dotenv.env['API_ENDPOINT']!.obs;
  RxString pc5BrokerUrl = (dotenv.env['PC5_MQTT_BROKER'] ?? "").obs;
  RxString issScmsToken = (dotenv.env['ISS_SCMS_TOKEN'] ?? "").obs;
  RxString cradleGPSUsername = (dotenv.env['GPS_USERNAME'] ?? "").obs;
  RxString cradleGPSPassword = (dotenv.env['GPS_PASSWORD'] ?? "").obs;
  RxString cradleGPSIP = (dotenv.env['GPS_IP'] ?? "").obs;
  RxString obuIP = (dotenv.env['OBU_IP'] ?? "").obs;
  RxString issMqttBrokerUrl = (dotenv.env['ISS_MQTT_BROKER'] ?? "").obs;
  RxString pathToFollow = ''.obs;
  RxString appVersion = ''.obs;
  Rx<bool> vzMode = false.obs;
  Rx<bool> notificationsEnabled = false.obs;
  Rx<bool> demoMode = false.obs;
  Rx<bool> readMessages = false.obs;
  Rx<bool> enableIssMqtt = true.obs;
  Rx<bool> enableEtxMqtt = true.obs;
  RxInt broadcastRate = 10.obs;

  RxList<String> availablePaths = <String>[].obs;

  Rx<double> staticGPSLatitude = 0.0.obs;
  Rx<double> staticGPSLongitude = 0.0.obs;

  Rx<bool> disableTUMRetry = false.obs;

  //GPS Mode
  Rx<GPSType> gpsType = GPSType.mobile.obs; // Default to mobile
  List<GPSType> gpsTypes = GPSType.values;


  // Automatically enable PC5 if the environment variable is configured
  Rx<bool> enablePC5 = dotenv.env['PC5_MQTT_BROKER'] != null ? true.obs : false.obs;

  RxString deviceID = ''.obs;
  RxString s3AccessKey = (dotenv.env['S3_ACCESS_KEY'] ?? "").obs;
  RxString s3SecretKey = (dotenv.env['S3_SECRET_KEY'] ?? "").obs;
  RxString s3BucketName = (dotenv.env['S3_BUCKET_NAME'] ?? "").obs;
  RxString s3Region = (dotenv.env['S3_REGION'] ?? "").obs;
  RxString s3DestDir = (dotenv.env['S3_DESTINATION'] ?? "").obs;

  RxBool changedBrokerSettings = false.obs; 

  Rx<IconSize> iconSize = IconSize.small.obs;
  Rx<bool> enableIssScmsSigning = false.obs;

  initialize() async {    
    baseUri.value = await secureStorage.getBaseURI();
    cradleGPSUsername.value = await secureStorage.getGPSUsername();
    cradleGPSPassword.value = await secureStorage.getGPSPassword();
    cradleGPSIP.value = await secureStorage.getGPSIP();
    obuIP.value = await secureStorage.getOBUIP();
    pathToFollow.value = await secureStorage.getPathToFollow();
    pc5BrokerUrl.value = await secureStorage.getPC5BrokerUrl();
    vzMode.value = await secureStorage.getVZMode();
    deviceID.value = await secureStorage.getDeviceID();
    notificationsEnabled.value = await secureStorage.getNotificationsEnabled();
    demoMode.value = await secureStorage.getDemoMode();
    readMessages.value = await secureStorage.getReadMessages();
    developerMode.value = await secureStorage.getDeveloperMode();
    soundEffectsEnabled.value = await secureStorage.getSoundEffectsEnabled();
    tollingEnabled.value = await secureStorage.getTollingEnabled();
    showTims.value = await secureStorage.getShowTims();
    staticGPSLatitude.value = await secureStorage.getStaticGPSLatitude();
    staticGPSLongitude.value = await secureStorage.getStaticGPSLongitude();
    enablePC5.value = await secureStorage.getPC5Enabled();
    enableIssMqtt.value = await secureStorage.getISSMqttEnabled();
    issMqttBrokerUrl.value = await secureStorage.getISSMqttBrokerUrl();
    enableEtxMqtt.value = await secureStorage.getEtxMqttEnabled();
    enableIssScmsSigning.value = await secureStorage.getIssScmsSigningEnabled();
    broadcastRate.value = await secureStorage.getBroadcastRate();
    gpsType.value = toGPSType(await secureStorage.getGPSType());

    if (gpsType.value == GPSType.mobile && Platform.isLinux) {
      gpsType.value = GPSType.cradle;
    }

    //filter gps types based on environment variables
    List<GPSType> filteredGPSTypes = [];
    if(showMobileGPSType) filteredGPSTypes.add(GPSType.mobile);
    if(showCradleGPSType) filteredGPSTypes.add(GPSType.cradle);
    if(showOBUGPSType) filteredGPSTypes.add(GPSType.obu);
    if(showPathGPSType) filteredGPSTypes.add(GPSType.path);
    if(showStaticGPSType) filteredGPSTypes.add(GPSType.static);
    gpsTypes = filteredGPSTypes;

    //check if the current gps type is in the filtered list, if not set to first available
    if(!gpsTypes.contains(gpsType.value) && gpsTypes.isNotEmpty){
      gpsType.value = gpsTypes[0];
    }

    bool? darkMode = await sharedPrefs.getDarkModeFromPrefs();
    if (darkMode != null) {
      if (darkMode) {
        Get.changeThemeMode(ThemeMode.dark);
        darkModeState.value = true;
      } else {
        Get.changeThemeMode(ThemeMode.light);
        darkModeState.value = false;
      }
    } else {
      Get.changeThemeMode(ThemeMode.system);
      bool isSystemDarkMode = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

      darkModeState.value = isSystemDarkMode;
    }

    iconSize = (await sharedPrefs.getIconSizeFromPrefs() ?? IconSize.small).obs;


    PackageInfo packageInfo = await PackageInfo.fromPlatform(); // Fetch the app version
    appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
  }

  Future<void> setup() async{
    apiService = Get.find<ApiService>();
    pathService = Get.find<PathService>();
    SecretResponse? secrets = await apiService.getSecrets();
    
    if (secrets != null) {
      issScmsToken.value = secrets.issScmsToken;
      s3AccessKey.value = secrets.s3.s3AccessKey;
      s3SecretKey.value = secrets.s3.s3SecretKey;
      s3BucketName.value = secrets.s3.s3BucketName;
      s3Region.value = secrets.s3.s3Region;
      s3DestDir.value = secrets.s3.s3Destination;
    }else{
      issScmsToken.value = await secureStorage.getIssScmsToken();
      s3AccessKey.value = await secureStorage.getS3AccessKey();
      s3SecretKey.value = await secureStorage.getS3SecretKey();
      s3BucketName.value = await secureStorage.getS3BucketName();
      s3Region.value = await secureStorage.getS3Region();
      s3DestDir.value = await secureStorage.getS3DestDir();
    }

    enableIssScmsSigning.value = issScmsToken.value.isNotEmpty;

    availablePaths.value = pathService.getPathNames();
    if(!availablePaths.contains(pathToFollow.value)){
      if(availablePaths.isEmpty){
        pathToFollow.value = '';
        return;
      }
      pathToFollow.value = availablePaths[0];
    }
    
  }

  Future logout() async {}

  @override
  void onInit() async {
    //await initialize();
    super.onInit();
  }

  void switchModeState() async {
    darkModeState.value = !darkModeState.value;
    if (darkModeState.value) {
      Get.changeThemeMode(ThemeMode.dark);
      await sharedPrefs.saveDarkModeToPrefs(darkModeState.value);
    } else {
      Get.changeThemeMode(ThemeMode.light);
      await sharedPrefs.saveDarkModeToPrefs(darkModeState.value);
    }
  }

  void setIconSize() async {
    await sharedPrefs.saveIconSizeToPrefs(iconSize.value);
  }

  GPSType toGPSType(String type) {
    switch (type.toLowerCase()) {
      case 'obu':
        return GPSType.obu;
      case 'cradle':
        return GPSType.cradle;
      case 'mobile':
        return GPSType.mobile;
      case 'path':
        return GPSType.path;
      case 'static':
        return GPSType.static;
      default:
        return GPSType.mobile; // Default to mobile if unknown
    }
  }
}
