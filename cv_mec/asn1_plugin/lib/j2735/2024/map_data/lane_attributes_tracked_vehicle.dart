import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesTrackedVehicle extends Choice_LaneTypeAttributes {
  late bool spec_RevocableLane;
  late bool spec_LightRailRoadTrack;
  late bool spec_HeavyRailRoadTrack;
  late bool spec_OtherRailType;

  LaneAttributesTrackedVehicle.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    spec_RevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    spec_LightRailRoadTrack = (decodedBits[0] & (1 << 6)) != 0;
    spec_HeavyRailRoadTrack = (decodedBits[0] & (1 << 5)) != 0;
    spec_OtherRailType = (decodedBits[0] & (1 << 4)) != 0;
  }
}
