import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;

class BrakeAppliedStatus {
  late bool unavailable;
  late bool leftFront;
  late bool leftRear;
  late bool rightFront;
  late bool rightRear;

  BrakeAppliedStatus.fromBitString(C.BIT_STRING_s bits) {
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailable = (decodedBits[0] & (1 << 0)) != 0;
    leftFront = (decodedBits[0] & (1 << 1)) != 0;
    leftRear = (decodedBits[0] & (1 << 2)) != 0;
    rightFront = (decodedBits[0] & (1 << 3)) != 0;
    rightRear = (decodedBits[0] & (1 << 4)) != 0;
  }
}
