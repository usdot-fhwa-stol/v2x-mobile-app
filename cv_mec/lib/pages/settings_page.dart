import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/vehicle_notification_manager.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  SettingsController controller = Get.find<SettingsController>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController baseUriController = TextEditingController();
  TextEditingController vendorIDController = TextEditingController();
  TextEditingController deviceIDController = TextEditingController();

  FileService fileService = Get.find<FileService>();

  SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    usernameController.text = controller.username.value;
    passwordController.text = controller.password.value;
    baseUriController.text = controller.baseUri.value;
    vendorIDController.text = controller.vendorID.value;
    deviceIDController.text = controller.deviceID.value;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings Page"),
        ),
        body: Container(
            child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(30.0),
            child: ListView(children: [
              versionHeader(),
              verticalSpaceMedium,
              accountSection(),
              verticalSpaceMedium,
              appearanceSection(),
            ]),
          ),
        )));
  }

  versionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "App Version: ${controller.appVersion.value}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }

  accountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerElement("Account", Icons.person),
        verticalSpaceSmall,
        TextField(
          decoration: const InputDecoration(labelText: 'Username'),
          controller: usernameController,
          obscureText: true,
          onChanged: (value) async {
            if (value != controller.username.value) {
              controller.username.value = value;
              await controller.secureStorage.setUsername(value);
            }
          },
        ),
        verticalSpaceMedium,
        TextField(
          decoration: const InputDecoration(labelText: 'Password'),
          controller: passwordController,
          obscureText: true,
          onChanged: (value) async {
            if (value != controller.password.value) {
              controller.password.value = value;
              await controller.secureStorage.setPassword(value);
            }
          },
        ),
        verticalSpaceMedium,
        TextField(
          decoration: const InputDecoration(labelText: 'Base URI'),
          controller: baseUriController,
          obscureText: true,
          onChanged: (value) async {
            if (value != controller.baseUri.value) {
              controller.baseUri.value = value;
              await controller.secureStorage.setBaseURI(value);
            }
          },
        ),
        verticalSpaceMedium,
        TextField(
          decoration: const InputDecoration(labelText: 'Vendor ID'),
          controller: vendorIDController,
          obscureText: true,
          onChanged: (value) async {
            if (value != controller.vendorID.value) {
              controller.vendorID.value = value;
              await controller.secureStorage.setVendorID(value);
            }
          },
        ),
        verticalSpaceMedium,
        TextField(
          decoration: const InputDecoration(labelText: 'Device ID'),
          controller: deviceIDController,
          obscureText: false,
          onChanged: (value) async {
            if (value != controller.deviceID.value) {
              controller.deviceID.value = value;
              await controller.secureStorage.setDeviceID(value);
            }
          },
        ),
        verticalSpaceMedium,
        SwitchListTile(
            title: const Text("VZ Mode"),
            value: controller.vzMode.value,
            onChanged: (value) async {
              if (value != controller.vzMode.value) {
                controller.vzMode.value = value;
                await controller.secureStorage.setVZMode(value);
              }
            }),
        verticalSpaceMedium,
        SwitchListTile(
            title: const Text("Enable Notifications"),
            value: controller.notificationsEnabled.value,
            onChanged: (value) async {
              if (value != controller.notificationsEnabled.value) {
                controller.notificationsEnabled.value = value;
                await controller.secureStorage.setNotificationsEnabled(value);
                if (controller.notificationsEnabled.value) {
                  //TODO: Fix icons
                  VehicleNotificationManager.notifyVehicleFromMessageAndImage(
                      "Notifications Enabled!", const AssetImage('assets/images/cv_mec_notification_icon.png'));
                }
              }
            }),
        verticalSpaceMedium,
        SwitchListTile(
            title: const Text("Read Messages"),
            value: controller.readMessages.value,
            onChanged: (value) async {
              if (value != controller.readMessages.value) {
                controller.readMessages.value = value;
                await controller.secureStorage.setReadMessages(value);
              }
            }),
        verticalSpaceMedium,
        SwitchListTile(
            title: const Text("Enable Demo Mode"),
            value: controller.demoMode.value,
            onChanged: (value) async {
              if (value != controller.demoMode.value) {
                controller.demoMode.value = value;
                await controller.secureStorage.setDemoMode(value);
              }
            }),
        verticalSpaceMedium,
      ],
    );
  }

  appearanceSection() {
    return Column(
      children: [
        headerElement("Appearance", Icons.image),
        appearanceSettings(),
      ],
    );
  }

  appearanceSettings() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            SwitchListTile(
                title: const Text("Dark Mode"),
                value: controller.darkModeState.value,
                onChanged: (value) {
                  controller.switchModeState();
                }),
            verticalSpaceMedium,
            SwitchListTile(
                title: const Text("Developer Mode"),
                value: controller.developerMode.value,
                onChanged: (value) async {
                  controller.developerMode.value = value;
                  await controller.secureStorage.setDeveloperMode(value);
                }),
          ],
        ));
  }

  inputValid() {
    if (usernameController.text.isEmpty) {
      return false;
    }
    if (passwordController.text.isEmpty) {
      return false;
    }
    if (baseUriController.text.isEmpty) {
      return false;
    }
    if (vendorIDController.text.isEmpty) {
      return false;
    }
    return true;
  }

  headerElement(String sectionTitle, IconData icon) {
    return Column(
      children: [
        Row(children: [
          Icon(icon,
              color: controller.darkModeState.value ? lightprimaryColor : primaryColor), //change color to match theme
          const SizedBox(width: 10),
          Text(sectionTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }
}
