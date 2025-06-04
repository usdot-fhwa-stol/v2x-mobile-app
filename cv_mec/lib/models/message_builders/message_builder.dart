import 'dart:ffi';
import 'dart:math';

import 'package:cv_mec/services/asn_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

abstract class MessageBuilder {
  late Pointer<Pointer<Void>> msgPtr;

  ASNService asnService = Get.find<ASNService>();
  Random random = Random();

  Pointer<Pointer<Void>> getNewTemplate();

  void setTime(DateTime time);
  DateTime getTime(DateTime time);

  void setPosition(Position position);
  LatLng getPosition();

  void incrementMsgCnt();

  String build() {
    return asnService.encode(msgPtr);
  }
}
