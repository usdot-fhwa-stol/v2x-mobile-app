import 'dart:async';

import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_event_responder_worker_type.dart';
import 'package:cv_mec/models/vehicle.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:get/get.dart';

class ConfigurationController extends GetxController {
  ConfigurationController();

  //Vehicle Configurations
  RxList<Vehicle> vehicleConfigs = <Vehicle>[].obs;

  Rx<Vehicle> selectedVehicle = Vehicle.detailed("Default", VehicleType.PASSENGER_VEHICLE, "Blue", 187, 70).obs;
  RxInt vehicleBeingEditedIndex = (-1).obs;
  FileService fileService = Get.find<FileService>();

  //Pedestrian Configurations
  PersonalDeviceUserType selectedPedestrian = PersonalDeviceUserType.APEDESTRIAN;
  PublicSafetyEventResponderWorkerType selectedPublicSafetyWorker = PublicSafetyEventResponderWorkerType.ADOTWORKER;

  //Siren Config
  RxBool isSirenOn = false.obs; //true for siren on, false for siren off
  RxInt sirenPhotoIndex = 0.obs;
  final images = [
    "assets/images/Siren/siren1.png",
    "assets/images/Siren/siren2.png",
    "assets/images/Siren/siren3.png",
    "assets/images/Siren/siren4.png",
  ];
  Timer? sirenTimer;

  //Bus Warning Config
  RxBool isBusWarningOn = false.obs; //true for bus warning on, false for bus warning off

  //Configuration State
  RxBool isVehicleConfig = true.obs; //true for vehicle, false for pedestrian

  initialize() async {
    vehicleConfigs.value = await fileService.getVehicleConfigsfromFile();
  }

  Future<void> addVehicleConfig(Vehicle vehicle) async {
    vehicleConfigs.add(vehicle);
    await fileService.saveVehicleConfigsToFile(vehicleConfigs);
  }

  Future<void> editVehicleConfig(Vehicle vehicle) async {
    if (vehicleBeingEditedIndex.value != -1) {
      vehicleConfigs[vehicleBeingEditedIndex.value] = vehicle;
      await fileService.saveVehicleConfigsToFile(vehicleConfigs);
    }
  }

  Future<void> deleteVehicleConfig(Vehicle vehicle) async {
    vehicleConfigs.remove(vehicle);
  }

  void setVehicleToDefault() {
    selectedVehicle.value = Vehicle.detailed("Default", VehicleType.PASSENGER_VEHICLE, "Blue", 187, 70);
    vehicleBeingEditedIndex.value = -1;
  }

  bool hasASiren() {
    if (isVehicleConfig.value) {
      return selectedVehicle.value.classification == VehicleType.POLICE ||
          selectedVehicle.value.classification == VehicleType.FIRE ||
          selectedVehicle.value.classification == VehicleType.AMBULANCE;
    } else {
      return false;
    }
  }

  bool isABus() {
    if (isVehicleConfig.value) {
      return selectedVehicle.value.classification == VehicleType.BUS;
    } else {
      return false;
    }
  }

  void startSiren() {
    sirenTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      sirenPhotoIndex.value = (sirenPhotoIndex.value + 1) % images.length;
    });
    isSirenOn.value = true;
  }

  void stopSiren() {
    sirenTimer?.cancel();
    sirenPhotoIndex.value = 0;
    isSirenOn.value = false;
  }

  @override
  void onInit() async {
    await initialize();
    super.onInit();
  }
}
