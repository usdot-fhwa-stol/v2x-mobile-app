import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesParking extends Choice_LaneTypeAttributes {
  late bool parkingRevocableLane;
  late bool parallelParkingInUse;
  late bool headInParkingInUse;
  late bool doNotParkZone;
  late bool parkingForBusUse;
  late bool parkingForTaxiUse;
  late bool noPublicParkingUse;

  LaneAttributesParking.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    parkingRevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    parallelParkingInUse = (decodedBits[0] & (1 << 6)) != 0;
    headInParkingInUse = (decodedBits[0] & (1 << 5)) != 0;
    doNotParkZone = (decodedBits[0] & (1 << 4)) != 0;
    parkingForBusUse = (decodedBits[0] & (1 << 3)) != 0;
    parkingForTaxiUse = (decodedBits[0] & (1 << 2)) != 0;
    noPublicParkingUse = (decodedBits[0] & (1 << 1)) != 0;
  }
}
