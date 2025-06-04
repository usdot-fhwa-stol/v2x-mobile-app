import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_event_responder_worker_type.dart';
import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/pages/map_page.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PublicSafetyWorkerDialog extends StatelessWidget {
  const PublicSafetyWorkerDialog({super.key});
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
                width: screenWidth(context) * 0.75,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    const CVMECText.styleTwo("Select a Config"),
                  ],
                ),
              ),
              verticalSpaceSmall,
              SizedBox(
                width: screenWidth(context) * 0.75,
                height: screenHeight(context) * 0.3,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...PublicSafetyEventResponderWorkerType.values
                        .skip(1)
                        .map((publicSafetyConfig) => ListTile(
                              leading: avatar(publicSafetyConfig),
                              title: enumToText(publicSafetyConfig),
                              onTap: () {
                                configController.selectedPublicSafetyWorker = publicSafetyConfig;
                                Get.off(() => MapPage());
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

  Text enumToText(PublicSafetyEventResponderWorkerType publicSafetyConfig) {
    switch (publicSafetyConfig) {
      case PublicSafetyEventResponderWorkerType.ADOTWORKER:
        return Text("DOT Worker");
      case PublicSafetyEventResponderWorkerType.ANIMALCONTROLERWORKER:
        return Text("Animal Control Worker");
      case PublicSafetyEventResponderWorkerType.FIREANDEMSWORKER:
        return Text("Fire and EMS Worker");
      case PublicSafetyEventResponderWorkerType.HAZMATRESPONDER:
        return Text("HAZMAT Responder");
      case PublicSafetyEventResponderWorkerType.LAWENFORCEMENT:
        return Text("Law Enforcement");
      case PublicSafetyEventResponderWorkerType.TOWOPERATOR:
        return Text("Tow Operator");
      case PublicSafetyEventResponderWorkerType.OTHERPERSONNEL:
        return Text("Other Personnel");
      default:
        return Text("Unknown");
    }
  }

  Widget avatar(PublicSafetyEventResponderWorkerType userConfig) {
    late IconData icon;
    switch (userConfig) {
      case PublicSafetyEventResponderWorkerType.ADOTWORKER:
        icon = Icons.construction;
        break;
      case PublicSafetyEventResponderWorkerType.ANIMALCONTROLERWORKER:
        icon = Icons.pets;
        break;
      case PublicSafetyEventResponderWorkerType.FIREANDEMSWORKER:
        icon = Icons.fire_extinguisher;
        break;
      case PublicSafetyEventResponderWorkerType.HAZMATRESPONDER:
        icon = Icons.dangerous_outlined;
        break;
      case PublicSafetyEventResponderWorkerType.LAWENFORCEMENT:
        icon = Icons.security;
        break;
      case PublicSafetyEventResponderWorkerType.OTHERPERSONNEL:
        icon = Icons.person;
        break;
      case PublicSafetyEventResponderWorkerType.TOWOPERATOR:
        icon = Icons.phishing;
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
