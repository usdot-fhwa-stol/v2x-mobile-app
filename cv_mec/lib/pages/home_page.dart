import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/pages/dev_page.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/text_styles.dart';
import 'package:cv_mec/styles/widgets/appbar.dart';
import 'package:cv_mec/styles/widgets/autosizetext.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:cv_mec/views/pedestrian_selection_dialog.dart';
import 'package:cv_mec/views/vehicle_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    SettingsController controller = Get.find<SettingsController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CVMecAppBar(title: "Home"),
      body: Obx(() => Center(
        child: SizedBox(
          height: screenHeight(context) * 0.8,
          child: Column(
            children: [
              verticalSpaceMedium,
              Image.asset(
                dotenv.env["LOGO_PATH"] ?? 'assets/images/Default/logo.png', 
                width: screenWidth(context) * 0.8,
                height: screenHeight(context) * 0.35,
              ),
              Flexible(child: Container()),
              startASession(context),
              controller.developerMode.value ? verticalSpaceMedium : Container(),
              controller.developerMode.value
                  ? SizedBox(
                      width: screenWidth(context) * 0.8,
                      child: ElevatedButton(
                          child: const Text("Dev Page"), onPressed: () => Get.to(() => const DevPage())))
                  : Container(),
              verticalSpaceLarge,
            ],
          ),
        )
      ))
    );
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            verticalSpaceSmall,
            const AutoSizeTextWidget(
              text: "Start a session",
              style: style_one,
              maxLines: 1,
            ),
            Flexible(child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.dialog(const VehicleConfigSelectionDialog());
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
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: AutoSizeTextWidget(
                            text: "Vehicle",
                            style: style_two,
                            maxLines: 1,
                          ),
                        ),
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
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: AutoSizeTextWidget(
                            text: "Pedestrian",
                            style: style_two,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Flexible(child: Container())
          ],
        ),
      ),
    );
  }
}
