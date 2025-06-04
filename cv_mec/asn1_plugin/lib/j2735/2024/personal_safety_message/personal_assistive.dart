import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class PersonalAssistive {
  late bool unavailble;
  late bool otherType;
  late bool vision;
  late bool hearing;
  late bool movement;
  late bool cognition;

  PersonalAssistive.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailble = (decodedBits[0] & (1 << 7)) != 0;
    otherType = (decodedBits[0] & (1 << 6)) != 0;
    vision = (decodedBits[0] & (1 << 5)) != 0;
    hearing = (decodedBits[0] & (1 << 4)) != 0;

    movement = (decodedBits[0] & (1 << 3)) != 0;
    cognition = (decodedBits[0] & (1 << 2)) != 0;
  }
}