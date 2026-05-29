import 'dart:io';
import 'package:cv_mec/pages/home_page.dart';
import 'package:cv_mec/pages/missing_permissions.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class Load extends StatelessWidget {
  const Load({super.key});

  Future _init() async {
    LocationService locationService = Get.find<LocationService>();
    await locationService.init();

    if(Platform.isAndroid || Platform.isIOS) {
      bool isTrackingGranted = await locationService.isTrackingGranted();
      bool isPermissionGranted = await locationService.isPermissionGranted();

      // Apple App store doesn't allow to clarify permissions. 
      if(Platform.isAndroid && !(isTrackingGranted && isPermissionGranted)) {
       Get.off(() => const MissingPermissions());
      }else{
        Get.put(ParamController(), permanent: true);
        Get.off(() => const HomePage());
      }
    }else {
      Get.put(ParamController(), permanent: true);
      Get.off(() => const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Center(
            child: SizedBox(
              width: screenWidth(context),
              height: screenHeight(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  image: DecorationImage(
                    image: AssetImage(dotenv.env["LOAD_PAGE_PATH"] ?? 'assets/images/Default/load_page.png'), 
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
