import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesCrosswalk extends Choice_LaneTypeAttributes {
  late bool crosswalkRevocableLane;
  late bool bicycleUseAllowed;
  late bool isXwalkFlyOverLane;
  late bool fixedCycleTime;
  late bool biDirectionalCycleTimes;
  late bool hasPutToWalkButton;
  late bool audioSupport;
  late bool rfSignalRequestPresent;
  late bool unsignalizedSegmentsPresent;

  LaneAttributesCrosswalk.fromBitString(C.BIT_STRING_s bits) {
    print(bits.size);

    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    crosswalkRevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    bicycleUseAllowed = (decodedBits[0] & (1 << 6)) != 0;
    isXwalkFlyOverLane = (decodedBits[0] & (1 << 5)) != 0;
    fixedCycleTime = (decodedBits[0] & (1 << 4)) != 0;
    biDirectionalCycleTimes = (decodedBits[0] & (1 << 3)) != 0;
    hasPutToWalkButton = (decodedBits[0] & (1 << 2)) != 0;
    audioSupport = (decodedBits[0] & (1 << 1)) != 0;
    rfSignalRequestPresent = (decodedBits[0] & (1 << 0)) != 0;

    // if(decodedBits.length > 0){
    unsignalizedSegmentsPresent = (decodedBits[1] & (1 << 7)) != 0;
  }
}
