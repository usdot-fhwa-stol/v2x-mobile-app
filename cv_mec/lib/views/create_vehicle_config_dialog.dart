import 'dart:io';
import 'package:bluetooth_classic/models/device.dart';
import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/models/us_states.dart';
import 'package:cv_mec/models/vehicle.dart';
import 'package:cv_mec/styles/screen_size.dart';
import 'package:cv_mec/styles/spacing.dart';
import 'package:cv_mec/styles/text_styles.dart';
import 'package:cv_mec/styles/widgets/autosizetext.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:cv_mec/views/bluetooth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../controllers/obd_controller.dart';

class CreateVehicleConfigDialog extends StatelessWidget {
  CreateVehicleConfigDialog({super.key});

  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleLengthController = TextEditingController();
  final TextEditingController vehicleWidthController = TextEditingController();
  USState licensePlateState = USState.ALABAMA;
  final TextEditingController licensePlateNumberController = TextEditingController();
  VehicleType? vehicleClassification;
  List<Color> vehicleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.grey,
    Colors.black,
    Colors.white,
  ];
  Rx<String> selectedColor = "".obs;
  Rx<String> obdIIaddress = "".obs;

  @override
  Widget build(BuildContext context) {
    ConfigurationController configController = Get.find<ConfigurationController>();
    if (configController.vehicleBeingEditedIndex.value != -1) {
      vehicleNameController.text = configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].name;
      vehicleNameController.text = configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].name;
      vehicleLengthController.text =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].length.toString();
      vehicleWidthController.text =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].width.toString();
      vehicleClassification =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].classification;
      selectedColor.value =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].color.toLowerCase();
      obdIIaddress.value =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].obdIIBluetoothAddress ?? "";
      licensePlateState =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].licensePlateState;
      licensePlateNumberController.text =
          configController.vehicleConfigs[configController.vehicleBeingEditedIndex.value].licensePlateNumber;
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: screenWidth(context) * 0.8,
        height: screenHeight(context) * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() => Column(
                children: [
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        configController.vehicleBeingEditedIndex.value = -1;
                        Get.back();
                      },
                    ),
                    const Flexible(  
                      child: AutoSizeTextWidget(
                        text: "Vehicle Configuration",
                        style: style_two,
                        maxLines: 2,
                      ),
                    ),
                  ]),
                  verticalSpaceSmall,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ListView(
                        children: [
                            SizedBox(width: screenWidth(context) * 0.8, child: CVMECText.styleThree("Config Name")),
                            verticalSpaceSmall,
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child:
                                  _inputField("Config Name", vehicleNameController, isRequired: true, context: context),
                            ),
                            verticalSpaceMedium,
                            SizedBox(width: screenWidth(context) * 0.8, child: CVMECText.styleThree("Vehicle Color")),
                            verticalSpaceSmall,
                            Obx(() => Wrap(children: [
                                  ...vehicleColors.map((color) => colorButton(color)).toList(),
                                ])),
                            verticalSpaceMedium,
                            SizedBox(
                                width: screenWidth(context) * 0.8,
                                child: CVMECText.styleThree("Vehicle Classification")),
                            verticalSpaceSmall,
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: _vehicleDropdownField(context),
                            ),
                            verticalSpaceMedium,
                            SizedBox(
                                width: screenWidth(context) * 0.8,
                                child: CVMECText.styleThree("Vehicle Length (Inch)")),
                            verticalSpaceSmall,
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: _inputField("Vehicle Length", vehicleLengthController,
                                  isRequired: true, isNumeric: true, context: context),
                            ),
                            verticalSpaceMedium,
                            SizedBox(
                                width: screenWidth(context) * 0.8, child: CVMECText.styleThree("Vehicle Width (Inch)")),
                            verticalSpaceSmall,
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: _inputField("Vehicle Width", vehicleWidthController,
                                  isRequired: true, isNumeric: true, context: context),
                            ),
                            verticalSpaceMedium,
                            SizedBox(
                                width: screenWidth(context) * 0.8,
                                child: CVMECText.styleThree("License Plate State")),
                            verticalSpaceSmall,
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: _licensePlateStateDropdownField(context),
                            ),
                            verticalSpaceMedium,
                            SizedBox(
                                width: screenWidth(context) * 0.8,
                                child: CVMECText.styleThree("License Plate Number")),
                            verticalSpaceSmall,
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: _inputField("License Plate Number", licensePlateNumberController,
                                  isRequired: true, isNumeric: false, context: context),
                            ),
                            verticalSpaceSmall,
                            if (Platform.isAndroid || Platform.isLinux)
                            SizedBox(
                              width: screenWidth(context) * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Flexible(
                                    child: const AutoSizeTextWidget(
                                      text: "OBD II Connection",
                                      style: style_three,
                                      maxLines: 2,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.bluetooth,
                                      color: obdIIaddress.value == "" ? Colors.red : Colors.green,
                                    ),
                                    onPressed: () async {
                                      OBDController obdController = Get.find<OBDController>();
                                      if (!obdController.bluetoothInitialized.value && !Platform.isLinux) {
                                        await obdController.initialize();
                                      }
                                      Device? device = await Get.dialog(bluetoothDialog());

                                      if (device != null) {
                                        obdIIaddress.value = device.address;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            CVMECText.styleFive(obdIIaddress.value == "" ? "Not Connected" : obdIIaddress.value),
                            verticalSpaceLarge,
                            saveButton(context),
                            const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _inputField(String labelText, TextEditingController controller,
      {bool isNumeric = false, bool isRequired = false, required BuildContext context}) {
    return TextField(
      decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor),
      controller: controller,
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isNumeric ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
    );
  }

  Widget _vehicleDropdownField(BuildContext context) {
    return DropdownButtonFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        value: vehicleClassification != "" ? vehicleClassification : null,
        isExpanded: true,
        menuMaxHeight: screenHeightPercentage(context, percentage: 0.5),
        dropdownColor: Theme.of(context).colorScheme.surface,
        //VehicleType.values.map((e) => e.name.replaceAll("_", " ").capitalizeFirst!).toList(),
        items: VehicleType.values
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.name.replaceAll("_", " ").capitalizeFirst!),
                ))
            .toList(),
        onChanged: (value) async {
          /*if (isVehicleClassification) {
            vehicleClassification = value.toString();
          }*/
          vehicleClassification = value;
        });
  }

  Widget _licensePlateStateDropdownField(BuildContext context) {
    return DropdownButtonFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        value: licensePlateState,
        isExpanded: true,
        menuMaxHeight: screenHeightPercentage(context, percentage: 0.5),
        dropdownColor: Theme.of(context).dialogBackgroundColor,
        items: USState.values
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.fullName),
                ))
            .toList(),
        onChanged: (value) async {
          if (value != null) {
            licensePlateState = value;
          }
        });
  }

  IconButton colorButton(Color color) {
    IconButton nonSelectedIconButton = IconButton(
      icon: Icon(Icons.circle, color: color.withOpacity(0.5)),
      onPressed: () {
        selectedColor.value = convertColorToString(color);
      },
    );
    IconButton selectedIconButton = IconButton(
      icon: Icon(Icons.star, color: color),
      onPressed: () {
        selectedColor.value = color.toString();
      },
    );
    return selectedColor.value == convertColorToString(color) ? selectedIconButton : nonSelectedIconButton;
  }

  Widget saveButton(BuildContext context) {
    return SizedBox(
      width: screenWidth(context) * 0.8,
      height: screenHeight(context) * 0.06,
      child: ElevatedButton(
        onPressed: () async {
          //Check to make sure all fields are filled out
          ConfigurationController configController = Get.find<ConfigurationController>();
          if (vehicleNameController.text.isEmpty ||
              vehicleLengthController.text.isEmpty ||
              vehicleWidthController.text.isEmpty ||
              selectedColor.value.isEmpty ||
              vehicleClassification == null) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text("Please fill out all fields"),
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
            );
          } else if (configController.vehicleBeingEditedIndex.value == -1 &&
              Get.find<ConfigurationController>()
                  .vehicleConfigs
                  .any((vehicle) => vehicle.name == vehicleNameController.text && vehicle.name != "")) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text("Config name already exists"), 
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
            );
          } else {
            //Save the vehicle configuration
            Vehicle vehicle = Vehicle.detailed(
                vehicleNameController.text,
                vehicleClassification ?? VehicleType.PASSENGER_VEHICLE,
                selectedColor.value,
                int.parse(vehicleLengthController.text),
                int.parse(vehicleWidthController.text),
                obdIIaddress.value.isEmpty ? null : obdIIaddress.value,
                licensePlateState,
                licensePlateNumberController.text
            );
            if (configController.vehicleBeingEditedIndex.value != -1) {
              //Edit existing vehicle config
              await configController.editVehicleConfig(vehicle);
              configController.vehicleBeingEditedIndex.value = -1;
              Get.back();
            } else {
              //Add new vehicle config
              await configController.addVehicleConfig(vehicle);
              Get.back();
            }
          }
        },
        child: const CVMECText.styleThree("Save"),
      ),
    );
  }

  String convertColorToString(Color color) {
    if (color == Colors.red) return "red";
    if (color == Colors.blue) return "blue";
    if (color == Colors.green) return "green";
    if (color == Colors.yellow) return "yellow";
    if (color == Colors.orange) return "orange";
    if (color == Colors.purple) return "purple";
    if (color == Colors.brown) return "brown";
    if (color == Colors.grey) return "grey";
    if (color == Colors.black) return "black";
    if (color == Colors.white) return "white";
    return "unknown"; // Fallback for unmapped colors
  }
}
