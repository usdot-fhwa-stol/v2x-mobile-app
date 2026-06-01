import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class MissingPermissions extends StatelessWidget {
  const MissingPermissions({super.key});
  @override
  Widget build(BuildContext context) {
    SettingsController controller = Get.find<SettingsController>();
    return Obx(() => Align(
      alignment: controller.screenLocation.value,
      child: Scaffold(
        body: SizedBox(
          width: screenWidth(context),
          height: screenHeight(context),
          child: Center(
            child: Column(
              children: [
                verticalSpaceMassive,
                Image.asset(
                  dotenv.env["LOGO_PATH"] ?? 'assets/images/Default/logo.png',
                  width: 200,
                  height: 200,
                ),
                verticalSpaceLarge,
                startASession(context),
              ],
            )
          )
        )
      )
    ));
  }

  Container startASession(BuildContext context) {
    return Container(
      width: screenWidth(context) * 0.8,
      height: screenHeight(context) * 0.4,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          verticalSpaceSmall,
          const CVMECText.styleTwo("Location and Tracking Services Required"),
          verticalSpaceSmall,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CVMECText.body(
              "This application uses your location to provide timely and accurate information that can enhance your safety. In order to use this application you must enable location permissions and tracking in the settings menu."),
          ),
          Expanded(child: Container()),
          ElevatedButton(
            onPressed: () => AppSettings.openAppSettings(),
            child: const Text('Open Location Settings'),
          ),
          verticalSpaceLarge,
        ],
      ),
    );
  }
}
