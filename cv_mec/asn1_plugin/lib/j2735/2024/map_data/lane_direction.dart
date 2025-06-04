import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class LaneDirection{
  late bool ingressPath;
  late bool egressPath;

  LaneDirection.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);
    ingressPath = (decodedBits[0] & (1 << 1)) != 0;
    egressPath = (decodedBits[0] & (1 << 0)) != 0;

  }
}