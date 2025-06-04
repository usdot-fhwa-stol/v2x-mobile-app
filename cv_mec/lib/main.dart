import 'package:cv_mec/pages/load.dart';
import 'package:cv_mec/services/vehicle_notification_manager.dart';
import 'package:cv_mec/styles/theme_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:cv_mec/pages/home_page.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:toastification/toastification.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(NativeDeviceOrientationReader(
    builder: (context) => const MainApp(),
  ));

  VehicleNotificationManager.requestPermissions();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'AMP',
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const Load(),
      ),
    );
  }
}
