import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';

class LaneAttributesStriping extends Choice_LaneTypeAttributes {
  late bool stripeToConnectingLanesRevocableLane;
  late bool stripeDrawOnLeft;
  late bool stripeDrawOnRight;
  late bool stripeToConnectingLanesLeft;
  late bool stripeToConnectingLanesRight;
  late bool stripeToConnectingLanesAhead;

  LaneAttributesStriping.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    stripeToConnectingLanesRevocableLane = (decodedBits[0] & (1 << 7)) != 0;
    stripeDrawOnLeft = (decodedBits[0] & (1 << 6)) != 0;
    stripeDrawOnRight = (decodedBits[0] & (1 << 5)) != 0;
    stripeToConnectingLanesLeft = (decodedBits[0] & (1 << 4)) != 0;
    stripeToConnectingLanesRight = (decodedBits[0] & (1 << 3)) != 0;
    stripeToConnectingLanesAhead = (decodedBits[0] & (1 << 2)) != 0;
  }
}
