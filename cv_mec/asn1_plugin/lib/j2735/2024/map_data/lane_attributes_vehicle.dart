import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesVehicle extends Choice_LaneTypeAttributes {
  late bool isVehicleRevocableLane;
  late bool isVehicleFlyOverLane;
  late bool hovLaneUseOnly;
  late bool restrictedToBusUse;
  late bool restrictedToTaxiUse;
  late bool restrictedFromPublicUse;
  late bool hasIRBeaconCoverage;
  late bool permissionOnRequest;

  LaneAttributesVehicle.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    isVehicleRevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    isVehicleFlyOverLane = (decodedBits[0] & (1 << 6)) != 0;
    hovLaneUseOnly = (decodedBits[0] & (1 << 5)) != 0;
    restrictedToBusUse = (decodedBits[0] & (1 << 4)) != 0;
    restrictedToTaxiUse = (decodedBits[0] & (1 << 3)) != 0;
    restrictedFromPublicUse = (decodedBits[0] & (1 << 2)) != 0;
    hasIRBeaconCoverage = (decodedBits[0] & (1 << 1)) != 0;
    permissionOnRequest = (decodedBits[0] & (1 << 0)) != 0;
  }
}
