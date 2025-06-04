import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesBike extends Choice_LaneTypeAttributes {
  late bool bikeRevocableLane;
  late bool pedestrianUseAllowed;
  late bool isBikeFlyOverLane;
  late bool fixedCycleTime;
  late bool biDirectionalCycleTimes;
  late bool isolatedByBarrier;
  late bool unsignalizedSegmentsPresent;
  LaneAttributesBike.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    bikeRevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    pedestrianUseAllowed = (decodedBits[0] & (1 << 6)) != 0;
    isBikeFlyOverLane = (decodedBits[0] & (1 << 5)) != 0;
    fixedCycleTime = (decodedBits[0] & (1 << 4)) != 0;
    biDirectionalCycleTimes = (decodedBits[0] & (1 << 3)) != 0;
    isolatedByBarrier = (decodedBits[0] & (1 << 2)) != 0;
    unsignalizedSegmentsPresent = (decodedBits[0] & (1 << 1)) != 0;
  }
}
