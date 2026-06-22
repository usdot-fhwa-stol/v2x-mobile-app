import 'dart:io';

import 'package:cv_mec/pages/load.dart';
import 'package:cv_mec/services/gpsd_service.dart';
import 'package:cv_mec/services/itis_decoding_service.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:cv_mec/services/path_service.dart';
import 'package:cv_mec/services/vehicle_notification_manager.dart';
import 'package:cv_mec/styles/theme_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/controllers/obd_controller.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/mqtt_service.dart';
import 'package:cv_mec/services/remote_gps.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:iss_scms/iss_scms.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await waitForNetwork();
  if (Platform.isAndroid || Platform.isIOS) {
    VehicleNotificationManager.requestPermissions();
  }


  await clearKeychainValues();
  Get.put(FileService());
  LoggingService loggingService = Get.put(LoggingService());
  Get.put(GeometryService());
  Get.put(LocationService());
  Get.put(Timing());
  SettingsController settingsController = Get.put(SettingsController());
  await settingsController.initialize();
  ApiService apiService = Get.put(ApiService());
  bool valid = await apiService.setupToken(); // Wait until API Token is fetched
  PathService pathService = Get.put(PathService());
  await pathService.loadPaths();
  settingsController.setup();
  
  Get.put(ConfigurationController());
  
  Get.put(ASNService());
  Get.put(RemoteGPSService());
  Get.put(GPSDService());
  Get.put(OBDController());
  Get.put(S3Service());
  Get.put(ItisDecodingService());
  Get.put(IssScms());
  loggingService.initialize();
  
  runApp(
    Platform.isAndroid || Platform.isIOS
        ? NativeDeviceOrientationReader(builder: (context) => MainApp())
        : MainApp(),
  );
}

Future<void> waitForNetwork() async {
  var result = await Connectivity().checkConnectivity();
  while (result == ConnectivityResult.none) {
    print('⏳ Waiting for network...');
    await Future.delayed(Duration(seconds: 1));
    result = await Connectivity().checkConnectivity();
  }
  print('✅ Network available!');
}

/*
On IOS Platforms keys stored in the secure storage keychain are not actually cleared when the app is uninstalled.
This can create problems if we change keys (like username / password) and result in the app retaining old keys for new versions
of the app. 

This function adds in a version number tag to the non-keychain stored parameters. This allows the app to detect if it is being launched
for the first time and to delete any old keys from the keychain. This allows the app to strategically pick when to clear keychain values
for new versions or updates. The current behavior is as follows
1) First Launch - Clear secure storage and load values from .env file
2) Updated version number - Clear secure storage and load values from .env file
3) App Opend for second time - Load values from Secure Storage. 
*/
Future<void> clearKeychainValues() async {
    final prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String firstLaunchKey = 'cv_mec_first_launch_' + packageInfo.buildNumber;

    if(prefs.getBool(firstLaunchKey) ?? true){
      FlutterSecureStorage storage = const FlutterSecureStorage();
      await storage.deleteAll();
      await prefs.setBool(firstLaunchKey, false);
    }
  }

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'V2X Mobile App',
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const Load(),
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
