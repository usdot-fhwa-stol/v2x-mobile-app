import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/models/vehicle.dart';
import 'package:cv_mec/pages/map_page.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/text_styles.dart';
import 'package:cv_mec/styles/theme_setting.dart';
import 'package:cv_mec/styles/widgets/autosizetext.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:cv_mec/views/create_vehicle_config_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleConfigSelectionDialog extends StatelessWidget {
  const VehicleConfigSelectionDialog({super.key});
  @override
  Widget build(BuildContext context) {
    ConfigurationController configController = Get.find<ConfigurationController>();
    Rx<bool> deleteConfigMode = false.obs;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: screenWidth(context) * 0.8,
        height: screenHeight(context) * 0.5,
        child: Center(
          child: Obx(() => Padding(
                padding: const EdgeInsets.only(left:16, right: 8, top: 24, bottom: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: screenWidth(context) * 0.8,
                      child: Row(
                        children: [
                          const Expanded(
                            child: AutoSizeTextWidget(
                              text: "Choose a vehicle",
                              style: style_two,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteConfigMode.value = !deleteConfigMode.value;
                            },
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceSmall,
                    Expanded(
                      child: SizedBox(
                        child: ListView(
                          children: [
                            ...configController.vehicleConfigs
                                .map((vehicle) => ListTile(
                                      leading: vehicleAvatar(vehicle),
                                      title: Text(vehicle.name),
                                      subtitle: AutoSizeTextWidget(
                                          text: vehicle.classification.name.replaceAll("_", " ").capitalizeFirst ?? "",
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                          maxLines: 2, overflow: TextOverflow.ellipsis, minFontSize: 8),
                                      trailing: !(deleteConfigMode.value)
                                          ? IconButton(
                                              icon: Icon(Icons.arrow_forward_ios,
                                                  color: Theme.of(context).colorScheme.onSurface),
                                              onPressed: () {
                                                configController.vehicleBeingEditedIndex.value =
                                                    configController.vehicleConfigs.indexOf(vehicle);
                                                Get.dialog(CreateVehicleConfigDialog());
                                              },
                                            )
                                          : IconButton(
                                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onSurface),
                                              onPressed: () {
                                                configController.deleteVehicleConfig(vehicle);
                                                deleteConfigMode.value = false;
                                              },
                                            ),
                                      onTap: () {
                                        configController.selectedVehicle.value = vehicle;
                                        configController.isVehicleConfig.value = true;
                                        Get.off(() => MapPage());
                                      },
                                    ))
                                .toList(),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Icon(Icons.add, color: isDark(Theme.of(context).primaryColor) ? Colors.white : Colors.black),
                              ),
                              title: Text("Add New"),
                              onTap: () {
                                Get.dialog(CreateVehicleConfigDialog());
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    verticalSpaceSmall,
                    ClickableText(
                      text: "Skip",
                      onTap: () {
                        configController.setVehicleToDefault();
                        configController.isVehicleConfig.value = true;
                        Get.off(() => const MapPage());
                      },
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Color getVehicleColor(String color) {
    switch (color.toLowerCase()) {
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "yellow":
        return Colors.yellow;
      case "orange":
        return Colors.orange;
      case "purple":
        return Colors.purple;
      case "brown":
        return Colors.brown;
      case "black":
        return Colors.black;
      case "white":
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  Widget getVehicleIcon(VehicleType classification) {
    switch (classification) {
      case VehicleType.PASSENGER_VEHICLE:
        return Image.asset(
          "assets/images/Vehicle_config_icons/passenger_vehicle.png",
          width: 30,
          height: 30,
        );
      case VehicleType.LIGHT_TRUCK:
        return Image.asset(
          "assets/images/Vehicle_config_icons/light_truck.png",
          width: 30,
          height: 30,
        );
      case VehicleType.TRUCK:
        return Image.asset(
          "assets/images/Vehicle_config_icons/truck.png",
          width: 30,
          height: 30,
        );
      case VehicleType.MOTORCYCLE:
        return Image.asset(
          "assets/images/Vehicle_config_icons/motorcycle.png",
          width: 30,
          height: 30,
        );
      case VehicleType.BUS:
        return Image.asset(
          "assets/images/Vehicle_config_icons/bus.png",
          width: 30,
          height: 30,
        );
      case VehicleType.FIRE:
        return const Icon(
          Icons.local_fire_department,
          color: Colors.black,
          size: 30,
        );
      case VehicleType.AMBULANCE:
        return const Icon(
          Icons.local_hospital,
          color: Colors.black,
          size: 30,
        );
      case VehicleType.POLICE:
        return const Icon(
          Icons.local_police,
          color: Colors.black,
          size: 30,
        );
      case VehicleType.ICE_CREAM_TRUCK:
        return Image.asset(
          "assets/images/Vehicle_config_icons/ice_cream_truck.png",
          width: 30,
          height: 30,
        );
      case VehicleType.OTHER:
        return const Icon(
          Icons.agriculture,
          color: Colors.black,
          size: 30,
        );
      default:
        return Image.asset(
          "assets/images/Vehicle_config_icons/passenger_vehicle.png",
          width: 30,
          height: 30,
        );
    }
  }

  Widget vehicleAvatar(Vehicle vehicle) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: getVehicleColor(vehicle.color),
          width: 3,
        ),
      ),
      child: Center(
        child: getVehicleIcon(vehicle.classification),
      ),
    );
  }
}
