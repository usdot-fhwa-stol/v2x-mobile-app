import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/pages/home_page.dart';
import 'package:cv_mec/pages/missing_permissions.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/location_service.dart';
import 'package:cv_mec/services/mqtt_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class Load extends StatelessWidget {
  const Load({super.key});

  Future _init() async {
    LocationService locationService = Get.put(LocationService());
    await locationService.init();
    if (!(await locationService.isPermissionGranted())) {
      Get.off(() => const MissingPermissions());
    } else {
      Get.put(Timing());
      Get.put(SettingsController());
      Get.put(ParamController());
      Get.put(ApiService());
      Get.put(ASNService());
      Get.put(FileService());
      Get.put(MqttService());
      Get.put(GeometryService());
      Get.put(S3Service());
      Get.put(ConfigurationController());
      Get.off(() => const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              image: DecorationImage(
                image: AssetImage('assets/images/load_page.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
  }
}
