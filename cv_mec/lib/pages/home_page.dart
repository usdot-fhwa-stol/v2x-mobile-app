import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/pages/dev_page.dart';
import 'package:cv_mec/pages/map_page.dart';
import 'package:cv_mec/pages/mqtt_page.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/mqtt_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/appbar.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:cv_mec/views/pedestrian_selection_dialog.dart';
import 'package:cv_mec/views/vehicle_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styles/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    /*Get.put(LocationService()); //TODO: Move all of these to a load page before redirecting to home
    Get.put(Timing());
    SettingsController controller = Get.put(SettingsController());
    Get.put(ParamController());
    Get.put(ApiService());
    Get.put(ASNService());
    Get.put(FileService());
    Get.put(MqttService());
    Get.put(GeometryService());
    Get.put(S3Service());
    Get.put(ConfigurationController());*/
    SettingsController controller = Get.find<SettingsController>();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CVMecAppBar(title: "Home"),
        body: Obx(() => Center(
                child: Column(
              children: [
                verticalSpaceLarge,
                Image.asset(
                  'assets/images/cvmec_logo.png',
                  width: 300,
                  height: 300,
                ),
                verticalSpaceLarge,
                verticalSpaceLarge,
                startASession(context),
                controller.developerMode.value ? verticalSpaceMedium : Container(),
                controller.developerMode.value
                    ? SizedBox(
                        width: screenWidth(context) * 0.8,
                        child: ElevatedButton(
                            child: const Text("Dev Page"), onPressed: () => Get.to(() => const DevPage())))
                    : Container(),
              ],
            ))));
  }

  Container startASession(BuildContext context) {
    SettingsController settingsController = Get.find<SettingsController>();
    return Container(
      width: screenWidth(context) * 0.8,
      height: screenHeight(context) * 0.32,
      decoration: BoxDecoration(
        color: settingsController.darkModeState.value ? darkGrey : lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          verticalSpaceSmall,
          const CVMECText.styleOne("Start a session"),
          verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  //Get.to(() => const VehicleConfigSelection());
                  Get.dialog(VehicleConfigSelectionDialog());
                },
                child: Container(
                  width: screenWidth(context) * 0.35,
                  height: screenHeight(context) * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        settingsController.darkModeState.value ? lightGrey.withOpacity(0.2) : darkGrey.withOpacity(0.2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      verticalSpaceSmall,
                      Icon(Icons.directions_car, size: 60),
                      verticalSpaceSmall,
                      CVMECText.styleTwo("Vehicle"),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.dialog(const PedestrianConfigSelectionDialog());
                },
                child: Container(
                  width: screenWidth(context) * 0.35,
                  height: screenHeight(context) * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        settingsController.darkModeState.value ? lightGrey.withOpacity(0.2) : darkGrey.withOpacity(0.2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      verticalSpaceSmall,
                      Icon(Icons.person, size: 60),
                      verticalSpaceSmall,
                      CVMECText.styleTwo("Pedestrian"),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
