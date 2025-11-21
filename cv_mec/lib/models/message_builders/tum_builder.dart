import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:asn1_plugin/j2735/2024/common/lightbar_in_use.dart';
import 'package:asn1_plugin/j2735/2024/common/siren_in_use.dart';
import 'package:asn1_plugin/j3217/2022/toll_usage_message/toll_usage_message.dart';
import 'package:ffi/ffi.dart';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/basic_vehicle_class.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/partii_id.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:cv_mec/models/message_builders/message_builder.dart';

class TumBuilder{
  //late C.TollUsageMessage tum;

  ASNService asnService = Get.find<ASNService>();

  TumBuilder();

  String buildCTum(TollUsageMessage tum) {
    print("Big Gorilla 1");
    final c_tum = tum.toC(calloc.allocate<C.TollUsageMessage>(sizeOf<C.TollUsageMessage>()));
    print("Big Gorilla 2");
    return "Big Gorilla - made it here";
  }
}
