import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesBarrier extends Choice_LaneTypeAttributes {
  late bool median_RevocableLane;
  late bool median;
  late bool whiteLineHashing;
  late bool stripedLines;
  late bool doubleStripedLines;
  late bool trafficCones;
  late bool constructionBarrier;
  late bool trafficChannels;
  late bool lowCurbs;
  late bool highCurbs;

  LaneAttributesBarrier.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    median_RevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    median = (decodedBits[0] & (1 << 6)) != 0;
    whiteLineHashing = (decodedBits[0] & (1 << 5)) != 0;
    stripedLines = (decodedBits[0] & (1 << 4)) != 0;
    doubleStripedLines = (decodedBits[0] & (1 << 3)) != 0;
    trafficCones = (decodedBits[0] & (1 << 2)) != 0;
    constructionBarrier = (decodedBits[0] & (1 << 1)) != 0;
    trafficChannels = (decodedBits[0] & (1 << 0)) != 0;
    lowCurbs = (decodedBits[1] & (1 << 7)) != 0;
    highCurbs = (decodedBits[1] & (1 << 6)) != 0;
  }
}
