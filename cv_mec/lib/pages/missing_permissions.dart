import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class MissingPermissions extends StatelessWidget {
  const MissingPermissions({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        verticalSpaceMassive,
        Image.asset(
          'assets/images/cvmec_logo.png',
          width: 200,
          height: 200,
        ),
        verticalSpaceLarge,
        startASession(context),
      ],
    )));
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
          const CVMECText.styleTwo("Location Services Required"),
          verticalSpaceSmall,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CVMECText.body(
                "Location permissions are required to use this application. Without them, timing and other components will not work correctly. Please change the app settings to allow location permissions and restart the app."),
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
