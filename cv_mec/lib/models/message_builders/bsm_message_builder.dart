import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:asn1_plugin/j2735/2024/common/lightbar_in_use.dart';
import 'package:asn1_plugin/j2735/2024/common/siren_in_use.dart';
import 'package:ffi/ffi.dart';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/basic_vehicle_class.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/partii_id.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:cv_mec/models/message_builders/message_builder.dart';

class BsmMessageBuilder extends MessageBuilder {
  late C.BasicSafetyMessage bsm;

  final String bsmTemplateString = "00142500000000003FFFF5A4E900EB49D20000007FFFFFFFFFFFF080FDFA1FA1007FFF8000000000";
  Pointer<C.BSMpartIIExtension> supplementalExtension = nullptr;
  Pointer<C.BSMpartIIExtension> vehicleSafetyExtension = nullptr;
  Pointer<C.BSMpartIIExtension> specialVehicleExtension = nullptr;

  ASNService asnService = Get.find<ASNService>();
  Random random = Random();

  BsmMessageBuilder() {
    msgPtr = getNewTemplate();

    Pointer<C.MessageFrame> messageFrameValuePtr = msgPtr.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    bsm = messageFrame.value.choice.BasicSafetyMessage;

    randomizeId();
  }

  @override
  String build() {
    int count = 0;
    if (supplementalExtension.address != 0) {
      count += 1;
    }

    if (vehicleSafetyExtension.address != 0) {
      count += 1;
    }

    if (specialVehicleExtension.address != 0) {
      count += 1;
    }

    if (bsm.partII.address == 0) {
      bsm.partII = calloc<C.BasicSafetyMessage__partII>();
      bsm.partII.ref.list.array = nullptr;
    }

    final newArray = calloc<Pointer<C.BSMpartIIExtension>>(count);
    bsm.partII.ref.list.count = count;

    int index = 0;

    if (vehicleSafetyExtension.address != 0) {
      newArray[index] = vehicleSafetyExtension;
      index += 1;
    }

    if (specialVehicleExtension.address != 0) {
      newArray[index] = specialVehicleExtension;
      index += 1;
    }

    if (supplementalExtension.address != 0) {
      newArray[index] = supplementalExtension;
    }

    bsm.partII.ref.list.array = newArray;

    return asnService.encode(msgPtr);
  }

  @override
  Pointer<Pointer<Void>> getNewTemplate() {
    return asnService.decode(bsmTemplateString);
  }

  @override
  void setTime(DateTime time) {
    bsm.coreData.secMark = time.millisecond + time.second * 1000;
  }

  @override
  DateTime getTime(DateTime time) {
    int second = bsm.coreData.secMark ~/ 1000;
    if (second > 50 && time.second < 10) {
      return DateTime(time.year, time.month, time.day, time.hour, time.minute, second, bsm.coreData.secMark % 1000)
          .subtract(const Duration(minutes: 1));
    } else {
      return DateTime(time.year, time.month, time.day, time.hour, time.minute, second, bsm.coreData.secMark % 1000);
    }
  }

  @override
  void setPosition(Position position) {
    bsm.coreData.Long = (position.longitude * 1E7).toInt();
    bsm.coreData.lat = (position.latitude * 1E7).toInt();
  }

  void setPositionLatLng(double latitude, double longitude) {
    bsm.coreData.Long = (longitude * 1E7).toInt();
    bsm.coreData.lat = (latitude * 1E7).toInt();
  }

  @override
  LatLng getPosition() {
    return LatLng(bsm.coreData.lat / 1E7.toInt(), bsm.coreData.Long / 1E7.toInt());
  }

  @override
  void incrementMsgCnt() {
    int msgCnt = bsm.coreData.msgCnt;
    msgCnt += 1;

    if (msgCnt > 127) {
      msgCnt = 0;
    }
    bsm.coreData.msgCnt = msgCnt;
  }

  void randomizeId() {
    List<int> randomNumbers = List.generate(4, (_) => random.nextInt(255));
    Uint8List dataBuffer = bsm.coreData.id.buf.asTypedList(randomNumbers.length);
    bsm.coreData.id.size = 4;
    dataBuffer.setAll(0, randomNumbers);
  }

  void clearVehicleExtensions() {}

  void setVehicleClass(BasicVehicleClass cls) {
    if (supplementalExtension.address == 0) {
      supplementalExtension = calloc<C.BSMpartIIExtension>();
    }

    supplementalExtension.ref.partII_Id = PartII_Id.supplemental_vehicle_ext.index;
    supplementalExtension.ref.partII_Value.present =
        C.BSMpartIIExtension__partII_Value_PR.BSMpartIIExtension__partII_Value_PR_SupplementalVehicleExtensions;

    if (supplementalExtension.ref.partII_Value.choice.SupplementalVehicleExtensions.classification.address == 0) {
      supplementalExtension.ref.partII_Value.choice.SupplementalVehicleExtensions.classification =
          calloc<C.BasicVehicleClass_t>();
    }

    supplementalExtension.ref.partII_Value.choice.SupplementalVehicleExtensions.classification.value =
        cls.basicVehicleClass;
  }

  void setEmergencyVehicleLights(LightbarInUse lights, SirenInUse sirens) {
    if (specialVehicleExtension.address == 0) {
      specialVehicleExtension = calloc<C.BSMpartIIExtension>();
    }

    specialVehicleExtension.ref.partII_Id = PartII_Id.special_vehicle_ext.index;
    specialVehicleExtension.ref.partII_Value.present =
        C.BSMpartIIExtension__partII_Value_PR.BSMpartIIExtension__partII_Value_PR_SpecialVehicleExtensions;

    Pointer<C.EmergencyDetails> vehicleAlerts = nullptr;

    if (specialVehicleExtension.ref.partII_Value.choice.SpecialVehicleExtensions.vehicleAlerts.address == 0) {
      vehicleAlerts = calloc<C.EmergencyDetails>();
    } else {
      vehicleAlerts = specialVehicleExtension.ref.partII_Value.choice.SpecialVehicleExtensions.vehicleAlerts;
    }

    vehicleAlerts.ref.lightsUse = lights.index;
    vehicleAlerts.ref.sirenUse = sirens.index;

    specialVehicleExtension.ref.partII_Value.choice.SpecialVehicleExtensions.vehicleAlerts = vehicleAlerts;
  }

  String getId(Pointer<Pointer<Void>> message) {
    final Uint8List byteList = bsm.coreData.id.buf.asTypedList(bsm.coreData.id.size);

    // Convert the byte list to a String (assuming UTF-8 encoding)
    return ASNService.bytesToHex(byteList);
  }
}
