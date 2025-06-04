import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/pages/map_page.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:cv_mec/views/public_safety_worker_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PedestrianConfigSelectionDialog extends StatelessWidget {
  const PedestrianConfigSelectionDialog({super.key});
  @override
  Widget build(BuildContext context) {
    ConfigurationController configController = Get.find<ConfigurationController>();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: screenWidth(context) * 0.8,
        height: screenHeight(context) * 0.5,
        child: Center(
          child: Column(
            children: [
              verticalSpaceMedium,
              SizedBox(
                width: screenWidth(context) * 0.7,
                child: CVMECText.styleTwo("Select a Config"),
              ),
              verticalSpaceSmall,
              SizedBox(
                width: screenWidth(context) * 0.75,
                height: screenHeight(context) * 0.3,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...PersonalDeviceUserType.values
                        .skip(1)
                        .map((userConfig) => ListTile(
                              leading: pedestrianAvatar(userConfig),
                              title: enumToText(userConfig),
                              onTap: () {
                                configController.selectedPedestrian = userConfig;
                                configController.isVehicleConfig.value = false;
                                if (userConfig == PersonalDeviceUserType.APUBLICSAFETYWORKER) {
                                  Get.dialog(PublicSafetyWorkerDialog());
                                } else {
                                  Get.off(() => MapPage());
                                }
                              },
                            ))
                        .toList(),
                  ],
                ),
              ),
              Expanded(child: Container()),
              ClickableText(
                text: "Skip",
                onTap: () {
                  configController.selectedPedestrian = PersonalDeviceUserType.APEDESTRIAN; // Default to pedestrian
                  configController.isVehicleConfig.value = false;
                  Get.off(() => const MapPage());
                },
              ),
              verticalSpaceMedium,
            ],
          ),
        ),
      ),
    );
  }

  Text enumToText(PersonalDeviceUserType userConfig) {
    switch (userConfig) {
      case PersonalDeviceUserType.APEDESTRIAN:
        return Text("Pedestrian");
      case PersonalDeviceUserType.APEDALCYCLIST:
        return Text("Pedal Cyclist");
      case PersonalDeviceUserType.APUBLICSAFETYWORKER:
        return Text("Public Safety Worker");
      case PersonalDeviceUserType.ANANIMAL:
        return Text("Animal");
      default:
        return Text("Unknown");
    }
  }

  Widget pedestrianAvatar(PersonalDeviceUserType userConfig) {
    late IconData icon;
    switch (userConfig) {
      case PersonalDeviceUserType.APEDESTRIAN:
        icon = Icons.person;
        break;
      case PersonalDeviceUserType.APEDALCYCLIST:
        icon = Icons.pedal_bike;
        break;
      case PersonalDeviceUserType.APUBLICSAFETYWORKER:
        icon = Icons.health_and_safety;
        break;
      case PersonalDeviceUserType.ANANIMAL:
        icon = Icons.pets;
        break;
      default:
        icon = Icons.person;
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor,
          width: 3,
        ),
      ),
      child: Center(child: Icon(icon)),
    );
  }
}
