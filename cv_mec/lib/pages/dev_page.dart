import 'package:cv_mec/pages/map_page.dart';
import 'package:cv_mec/pages/mqtt_page.dart';
import 'package:cv_mec/styles/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DevPage extends StatelessWidget {
  const DevPage({super.key});
  @override
  Widget build(BuildContext context) {
    const String appTitle = "Developer Page";
    return Scaffold(
        appBar: CVMecAppBar(title: appTitle),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => const MQTTTesting());
              },
              child: const Text('MQTT Testing'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const MapPage());
              },
              child: const Text('Map'),
            ),
          ],
        )));
  }
}
