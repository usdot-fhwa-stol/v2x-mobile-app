import 'package:get/get.dart';

class ParamController extends GetxController {
  RxString clientType = ''.obs;
  RxString clientSubtype = ''.obs;
  RxString messageFormat = ''.obs;
  RxString v2xType = ''.obs;
  RxString networkType = "non-VZ".obs;
  RxBool networkTypeToggle = true.obs;
  RxBool useFakePositionToggle = false.obs;
  bool usingFakePosition = false;
  RxDouble fakeLatitude = 0.0.obs;
  RxDouble fakeLongitude = 0.0.obs;
  RxInt messageDelay = 0.obs;
  RxBool geoRelevanceOrPrivateToggle = true.obs; //false is geo, true is private
  bool geoRelevanceOrPrivate = true; //false is geo, true is private
  RxString privateDeviceID = ''.obs;

  @override
  onInit() {
    loadDefaults();
    super.onInit();
  }

  void loadDefaults() {
    clientType.value = "Vehicle";
    clientSubtype.value = "PassengerCar";
    messageFormat.value = "j2735_gr";
    v2xType.value = "BSM";
    networkType.value = "non-VZ"; //"VZ";
    useFakePositionToggle.value = false;
    usingFakePosition = false;

    // Turner Fairbanks
    fakeLatitude.value = 38.9555;
    fakeLongitude.value = -77.1494;

    // Colorado
    // fakeLatitude.value = 39.58937188602476;
    // fakeLongitude.value = -105.0912699992925;

    // Atlanta
    // fakeLatitude.value = 34.05640313666031;
    // fakeLongitude.value = -84.2769675541679;

    // New York
    // fakeLatitude.value = 40.788188;
    // fakeLongitude.value = -74.163805;

    messageDelay.value = 1000;
    geoRelevanceOrPrivateToggle.value = true;
    geoRelevanceOrPrivate = true;
    privateDeviceID.value = "self";
  }

  void saveParams(
      {required String clientType,
      required String clientSubtype,
      required String messageFormat,
      required String v2xType,
      required double fakeLatitude,
      required double fakeLongitude,
      required int messageDelay,
      required String privateDeviceID}) {
    this.clientType.value = clientType;
    this.clientSubtype.value = clientSubtype;
    this.messageFormat.value = messageFormat;
    networkType.value = networkTypeToggle.value ? "VZ" : "non-VZ";
    usingFakePosition = useFakePositionToggle.value;
    this.fakeLatitude.value = fakeLatitude;
    this.fakeLongitude.value = fakeLongitude;
    this.messageDelay.value = messageDelay;
    geoRelevanceOrPrivate = geoRelevanceOrPrivateToggle.value;
    this.privateDeviceID.value = privateDeviceID;
  }
}
