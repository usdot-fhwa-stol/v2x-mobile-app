import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double screenWidth(BuildContext context) { 
  SettingsController settingsController = Get.find<SettingsController>();
  if (settingsController.screenWidth.value != 0 && settingsController.showScreenSizeSettings.value) {
    return settingsController.screenWidth.value.toDouble();
  }
  return MediaQuery.of(context).size.width; 
}
double screenHeight(BuildContext context) { 
  SettingsController settingsController = Get.find<SettingsController>();
  if (settingsController.screenHeight.value != 0 && settingsController.showScreenSizeSettings.value) {
    return settingsController.screenHeight.value.toDouble();
  }
  return MediaQuery.of(context).size.height;
}
double screenHeightPercentage(BuildContext context, {double percentage = 1}) => screenHeight(context) * percentage;
double screenWidthPercentage(BuildContext context, {double percentage = 1}) => screenWidth(context) * percentage;