import 'dart:io';

import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/vehicle_notification_manager.dart';
import 'package:cv_mec/styles/app_colors.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/widgets/autosizetext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:cv_mec/models/RangeInputFormatter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  SettingsController controller = Get.find<SettingsController>();
  ParamController paramController = Get.find<ParamController>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController baseUriController = TextEditingController();
  TextEditingController deviceIDController = TextEditingController();
  TextEditingController gpsIPController = TextEditingController();
  TextEditingController gpsUsernameController = TextEditingController();
  TextEditingController gpsPasswordController = TextEditingController();
  TextEditingController obuIPController = TextEditingController();
  TextEditingController pc5BrokerUrlController = TextEditingController();
  TextEditingController issScmsTokenController = TextEditingController();
  TextEditingController registrationLatitudeController = TextEditingController();
  TextEditingController registrationLongitudeController = TextEditingController();
  TextEditingController scmsApiTokenController = TextEditingController();
  TextEditingController broadcastRateController = TextEditingController();
  TextEditingController staticGPSLatitudeController = TextEditingController();
  TextEditingController staticGPSLongitudeController = TextEditingController();
  TextEditingController issMqttBrokerUrlController = TextEditingController();


  FileService fileService = Get.find<FileService>();
  

  

  SettingsPage({super.key});


  @override
  Widget build(BuildContext context) {
    usernameController.text = controller.username.value;
    passwordController.text = controller.password.value;
    baseUriController.text = controller.baseUri.value;
    deviceIDController.text = controller.deviceID.value;
    gpsIPController.text = controller.cradleGPSIP.value;
    gpsUsernameController.text = controller.cradleGPSUsername.value;
    gpsPasswordController.text = controller.cradleGPSPassword.value;
    obuIPController.text = controller.obuIP.value;
    pc5BrokerUrlController.text = controller.pc5BrokerUrl.value;
    issScmsTokenController.text = controller.issScmsToken.value;
    broadcastRateController.text = controller.broadcastRate.value.toString();
    registrationLatitudeController.text = paramController.manualLatitude.toString();
    registrationLongitudeController.text = paramController.manualLongitude.toString();
    staticGPSLatitudeController.text = controller.staticGPSLatitude.value.toString();
    staticGPSLongitudeController.text = controller.staticGPSLongitude.value.toString();
    issMqttBrokerUrlController.text = controller.issMqttBrokerUrl.value;

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
            configurationSection(),
            verticalSpaceMedium,
            appearanceSection(),
          ]),
        ),
      ))
    );
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

  configurationSection() {
    if (Platform.isLinux) { //don't show mobile GPS option on Linux since it's not supported
      bool hasMobile = controller.gpsTypes.contains(GPSType.mobile);
      if (hasMobile) {
        controller.gpsTypes.remove(GPSType.mobile);
      }
    }
    return Column(
      children: [
        headerElement("Configuration", Icons.settings),
        verticalSpaceMedium,
        controller.gpsTypes.isNotEmpty
          ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final bool useStackedLayout =
                        MediaQuery.textScalerOf(context).scale(16) >= 20 || constraints.maxWidth < 420;

                    Widget gpsTypeDropdown = DropdownButton<GPSType>(
                      isExpanded: true,
                      dropdownColor: Theme.of(Get.context!).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      value: controller.gpsType.value,
                      items: (controller.gpsTypes).map((GPSType type) {
                        return DropdownMenuItem<GPSType>(
                          value: type,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              type.toString().split('.').last.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.gpsType.value = value;
                          controller.secureStorage.setGPSType(value);
                        }
                      },
                    );

                    if (useStackedLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("GPS Mode:", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          gpsTypeDropdown,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        const Text("GPS Mode:", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(child: gpsTypeDropdown),
                      ],
                    );
                  }),
                )
            : Text('No GPS types available', style: TextStyle(color: Theme.of(Get.context!).textTheme.bodyMedium!.color!)),
        verticalSpaceSmall,
        Obx(() => controller.gpsType.value == GPSType.cradle
            ? Column(children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'GPS IP'),
                  controller: gpsIPController,
                  obscureText: false,
                  onChanged: (value) async {
                    if (value != controller.cradleGPSIP.value) {
                      controller.cradleGPSIP.value = value;
                      await controller.secureStorage.setGPSIP(value);
                    }
                  },
                ),
                verticalSpaceSmall,
                TextField(
                  decoration: const InputDecoration(labelText: 'GPS Username'),
                  controller: gpsUsernameController,
                  obscureText: true,
                  onChanged: (value) async {
                    if (value != controller.cradleGPSUsername.value) {
                      controller.cradleGPSUsername.value = value;
                      await controller.secureStorage.setGPSUsername(value);
                    }
                  },
                ),
                verticalSpaceSmall,
                TextField(
                  decoration: const InputDecoration(labelText: 'GPS Password'),
                  controller: gpsPasswordController,
                  obscureText: true,
                  onChanged: (value) async {
                    if (value != controller.cradleGPSPassword.value) {
                      controller.cradleGPSPassword.value = value;
                      await controller.secureStorage.setGPSPassword(value);
                    }
                  },
                ),
              ])
            : const SizedBox.shrink()),
        Obx(() => controller.gpsType.value == GPSType.obu
            ? Column(children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'OBU IP'),
                  controller: obuIPController,
                  obscureText: false,
                  onChanged: (value) async {
                    if (value != controller.obuIP.value) {
                      controller.obuIP.value = value;
                      await controller.secureStorage.setOBUIP(value);
                    }
                  },
                ),
              ])
            : const SizedBox.shrink()),
        controller.showOBUGPSType ? verticalSpaceSmall : Container(),
        Obx(() => controller.gpsType.value == GPSType.path
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: LayoutBuilder(builder: (context, constraints) {
                  final bool useStackedLayout =
                      MediaQuery.textScalerOf(context).scale(16) >= 20 || constraints.maxWidth < 420;

                  Widget pathSelector = controller.availablePaths.isNotEmpty
                      ? DropdownButton<String>(
                          isExpanded: true,
                          value: controller.pathToFollow.value,
                          hint: const Text('Select an option'),
                          dropdownColor: Theme.of(Get.context!).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          items: controller.availablePaths.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != controller.pathToFollow.value) {
                              if (newValue != null) {
                                controller.pathToFollow.value = newValue;
                                controller.secureStorage.setPathToFollow(newValue);
                              }
                            }
                          },
                        )
                      : Text(
                          'No paths available',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Theme.of(Get.context!).textTheme.bodyMedium!.color!),
                        );

                  if (useStackedLayout) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Path Selection:", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        pathSelector,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      const Expanded(
                        flex: 4,
                        child: Text(
                          "Path Selection:",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(flex: 6, child: pathSelector),
                    ],
                  );
                }),
              )
            : const SizedBox.shrink()),
        Obx(() => controller.gpsType.value == GPSType.static
            ? Column(children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Static GPS Latitude'),
                  controller: staticGPSLatitudeController,
                  obscureText: false,
                  onChanged: (value) async {
                    if (value != controller.staticGPSLatitude.value.toString()) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        controller.staticGPSLatitude.value = parsed;
                        await controller.secureStorage.setStaticGPSLatitude(parsed);
                      }
                    }
                  },
                ),
                verticalSpaceSmall,
                TextField(
                  decoration: const InputDecoration(labelText: 'Static GPS Longitude'),
                  controller: staticGPSLongitudeController,
                  obscureText: false,
                  onChanged: (value) async {
                    if (value != controller.staticGPSLongitude.value.toString()) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        controller.staticGPSLongitude.value = parsed;
                        await controller.secureStorage.setStaticGPSLongitude(parsed);
                      }
                    }
                  },
                ),
              ])
            : const SizedBox.shrink(),
        ),
        verticalSpaceSmall,
        controller.showPathGPSType ? verticalSpaceSmall : Container(),
        controller.gpsType.value == GPSType.path ? verticalSpaceMedium : Container(), //add spacing if path GPS type is selected to keep spacing consistent
        controller.showBroadcastRate ? TextField(
          decoration: const InputDecoration(labelText: 'Broadcast Rate'),
          controller: broadcastRateController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Only allow 0–9
            RangeInputFormatter(min: 1, max: 10),
          ],
          onChanged: (value) async {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed != controller.broadcastRate.value) {
              controller.broadcastRate.value = parsed;
              await controller.secureStorage.setBroadcastRate(parsed);
            }
          },
        ) : Container(),
        controller.showBroadcastRate ? verticalSpaceSmall : Container(),
        controller.showPc5 ? SwitchListTile(
            title: const Text("Enable PC5 MQTT Broker"),
            value: controller.enablePC5.value,
            onChanged: (value) async {
              if (value != controller.enablePC5.value) {
                controller.enablePC5.value = value;
                await controller.secureStorage.setPC5Enabled(value);
                controller.changedBrokerSettings.value = true; 
              }
            }) : Container(),
        Obx(() => (controller.enablePC5.value && controller.showPc5)
            ? TextField(
                decoration: const InputDecoration(labelText: 'PC5 MQTT Broker URL'),
                controller: pc5BrokerUrlController,
                obscureText: false,
                onChanged: (value) async {
                  if (value != controller.pc5BrokerUrl.value) {
                    controller.pc5BrokerUrl.value = value;
                    await controller.secureStorage.setPC5BrokerUrl(value);
                  }
                },
              )
            : const SizedBox.shrink()),
        controller.showPc5 ? verticalSpaceSmall : Container(),
        controller.showIss ? SwitchListTile(
            title: const Text("Enable ISS MQTT Broker"),
            value: controller.enableIssMqtt.value,
            onChanged: (value) async {
              if (value != controller.enableIssMqtt.value) {
                controller.enableIssMqtt.value = value;
                await controller.secureStorage.setIssMqttEnabled(value);
                controller.changedBrokerSettings.value = true; 
              }
            }
          ) : Container(),
        verticalSpaceSmall,
        (controller.showIssBrokerUrl && controller.enableIssMqtt.value) ? TextField(
          decoration: const InputDecoration(labelText: 'ISS MQTT Broker URL'),
          controller: issMqttBrokerUrlController,
          onChanged: (value) async {
            if (value != controller.issMqttBrokerUrl.value) {
              controller.issMqttBrokerUrl.value = value;
              await controller.secureStorage.setISSMqttBrokerUrl(value);
            }
          },
        ) : Container(),
        controller.showIssBrokerUrl ? verticalSpaceSmall : Container(),
        controller.showIss ? verticalSpaceSmall : Container(),
        controller.showEtx ? SwitchListTile(
            title: const Text("Enable ETX MQTT Broker"),
            value: controller.enableEtxMqtt.value,
            onChanged: (value) async {
              if (value != controller.enableEtxMqtt.value) {
                controller.enableEtxMqtt.value = value;
                await controller.secureStorage.setEtxMqttEnabled(value);
                controller.changedBrokerSettings.value = true; 
              }
            }) : Container(),
        controller.showEtx ? verticalSpaceSmall : Container(),
        controller.showManualRegistration ? Obx(() => SwitchListTile(
            title: const Text("Enable Manual Registration"),
            value: paramController.manualRegistrationMode.value,
            onChanged: (value) async {
              if (value != paramController.manualRegistrationMode.value) {
                //paramController.manualRegistrationMode.value = value;
                await paramController.switchManualRegistrationMode();
                await controller.secureStorage.setManualRegistrationModeEnabled(value);
                controller.changedBrokerSettings.value = true; 
              }
            })) : Container(),
        Obx(() => (paramController.manualRegistrationMode.value && controller.showManualRegistration)
            ? Column(
              children: [
                TextField(
                    decoration: const InputDecoration(labelText: 'Registration Latitude'),
                    controller: registrationLatitudeController,
                    onChanged: (value) async {
                      if (value != paramController.registrationLatitude.value.toString()) {
                        paramController.manualLatitude = double.tryParse(value) ?? 0.0;
                        paramController.registrationLatitude.value = double.tryParse(value) ?? 0.0;
                        await controller.secureStorage.setRegistrationLatitude(paramController.registrationLatitude.value);
                      }
                    },
                  ),
                verticalSpaceSmall,
                TextField(
                  decoration: const InputDecoration(labelText: 'Registration Longitude'),
                  controller: registrationLongitudeController,
                  onChanged: (value) async {
                    if (value != paramController.registrationLongitude.value.toString()) {
                      paramController.manualLongitude = double.tryParse(value) ?? 0.0;
                      paramController.registrationLongitude.value = double.tryParse(value) ?? 0.0;
                      await controller.secureStorage.setRegistrationLongitude(paramController.registrationLongitude.value);
                    }
                  },
                )
              ],
            )
            : Container()),
        controller.showVzMode ? verticalSpaceSmall : Container(),
        controller.showVzMode ? Obx(() => SwitchListTile(
            title: const Text("VZ Mode"),
            value: controller.vzMode.value,
            onChanged: (value) async {
              if (value != controller.vzMode.value) {
                controller.vzMode.value = value;
                await controller.secureStorage.setVZMode(value);
              }
            })) : Container(),
        controller.showVzMode ? verticalSpaceSmall : Container(),
        Obx(() => SwitchListTile(
            title: const Text("Enable Notifications"), 
            value: controller.notificationsEnabled.value,
            onChanged: (value) async {
              if (value != controller.notificationsEnabled.value) {
                controller.notificationsEnabled.value = value;
                await controller.secureStorage.setNotificationsEnabled(value);
                if (controller.notificationsEnabled.value) {
                  VehicleNotificationManager.notifyVehicleFromMessageAndImage(
                      "Notifications Enabled!", AssetImage(dotenv.env["NOTIFICATION_ICON_PATH"] ?? 'assets/images/Sample/notification_icon.png')); 
                }
              }
            })),
        verticalSpaceSmall,
        SwitchListTile(
                title: const Text("Allow Sound Effects"),
                value: controller.soundEffectsEnabled.value,
                onChanged: (value) async {
                  controller.soundEffectsEnabled.value = value;
                  await controller.secureStorage.setSoundEffectsEnabled(value);
                }),
            verticalSpaceSmall,
        Obx(() => SwitchListTile(
            title: const Text("Read Messages"),
            value: controller.readMessages.value,
            onChanged: (value) async {
              if (value != controller.readMessages.value) {
                controller.readMessages.value = value;
                await controller.secureStorage.setReadMessages(value);
              }
            })),
        verticalSpaceSmall,
        controller.showDemoMode ? Obx(() => SwitchListTile(
            title: const Text("Enable Demo Mode"),
            value: controller.demoMode.value,
            onChanged: (value) async {
              if (value != controller.demoMode.value) {
                controller.demoMode.value = value;
                await controller.secureStorage.setDemoMode(value);
              }
            })) : Container(),
        controller.showDemoMode ? verticalSpaceSmall : Container(),
        controller.showSigning ? SwitchListTile(
            title: const Text("Enable Signing"),
            value: controller.enableIssScmsSigning.value,
            onChanged: (value) async {
              if (value != controller.enableIssScmsSigning.value) {
                controller.enableIssScmsSigning.value = value;
                await controller.secureStorage.setIssScmsSigningEnabled(value);
              }
            }) : Container(),
        controller.showSigning ? verticalSpaceSmall : Container(),
        controller.showDisableTUMRetry ? SwitchListTile(
            title: const Text("Disable TUM Message Retry"),
            value: controller.disableTUMRetry.value,
            onChanged: (value) async {
              if (value != controller.disableTUMRetry.value) {
                controller.disableTUMRetry.value = value;
                await controller.secureStorage.setDisableTUMRetry(value);
              }
            }) : Container(),            
        controller.showDisableTUMRetry ? verticalSpaceMedium : Container(),
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
            verticalSpaceSmall,
            Platform.isLinux ? Obx(() => Row(
              children: [
                const SizedBox(width: 14),
                const Text("Icon Size: ", style: TextStyle(fontSize: 16)),
                Expanded(child: Container()),
                DropdownButton<IconSize>(  
                  dropdownColor: Theme.of(Get.context!).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  value: controller.iconSize.value,
                  items: IconSize.values.map((IconSize size) {
                    return DropdownMenuItem<IconSize>(
                      value: size,
                      child: Text(size.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.iconSize.value = value;
                      controller.setIconSize();
                    }
                  },
                ),
              ],
            )) : Container(),
            controller.showTollingSettings ? SwitchListTile(
                title: const Text("Show Tolling"),
                value: controller.tollingEnabled.value,
                onChanged: (value) async {
                  controller.tollingEnabled.value = value;
                  await controller.secureStorage.setTollingEnabled(value);
                }) : Container(),
            verticalSpaceMedium,
            controller.showTimsSettings ? SwitchListTile(
                title: const Text("Show TIMs"),
                value: controller.showTims.value,
                onChanged: (value) async {
                  controller.showTims.value = value;
                  await controller.secureStorage.setShowTims(value);
                }) : Container(),
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
    return true;
  }

  headerElement(String sectionTitle, IconData icon) {
    return Column(
      children: [
        Row(children: [
            Icon(icon,
              color: controller.darkModeState.value ? darkPrimaryColor : primaryColor),
          const SizedBox(width: 10),
          Text(sectionTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }
}
