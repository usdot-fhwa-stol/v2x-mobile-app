import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesSidewalk extends Choice_LaneTypeAttributes {
  late bool sidewalk_RevocableLane;
  late bool bicycleUseAllowed;
  late bool isSidewalkFlyOverLane;
  late bool walkBikes;

  LaneAttributesSidewalk.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    sidewalk_RevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    bicycleUseAllowed = (decodedBits[0] & (1 << 6)) != 0;
    isSidewalkFlyOverLane = (decodedBits[0] & (1 << 5)) != 0;
    walkBikes = (decodedBits[0] & (1 << 4)) != 0;
  }
}
