import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class UserSizeAndBehavior {
  late bool unavailable;
  late bool smallSature;
  late bool largeStature;
  late bool erraticMoving;
  late bool slowMoving;

  UserSizeAndBehavior.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailable = (decodedBits[0] & (1 << 7)) != 0;
    smallSature = (decodedBits[0] & (1 << 6)) != 0;
    largeStature = (decodedBits[0] & (1 << 5)) != 0;
    erraticMoving = (decodedBits[0] & (1 << 4)) != 0;
    slowMoving = (decodedBits[0] & (1 << 3)) != 0;
  }
}