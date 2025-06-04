import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;

class HeadingSlice {
  bool from000_0to022_5degrees = false;
  bool from022_5to045_0degrees = false;
  bool from045_0to067_5degrees = false;
  bool from067_5to090_0degrees = false;

  bool from090_0to112_5degrees = false;
  bool from112_5to135_0degrees = false;
  bool from135_0to157_5degrees = false;
  bool from157_5to180_0degrees = false;

  bool from180_0to202_5degrees = false;
  bool from202_5to225_0degrees = false;
  bool from225_0to247_5degrees = false;
  bool from247_5to270_0degrees = false;

  bool from270_0to292_5degrees = false;
  bool from292_5to315_0degrees = false;
  bool from315_0to337_5degrees = false;
  bool from337_5to360_0degrees = false;


  HeadingSlice.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    from000_0to022_5degrees = (decodedBits[0] & (1 << 7)) != 0;
    from022_5to045_0degrees = (decodedBits[0] & (1 << 6)) != 0;
    from045_0to067_5degrees = (decodedBits[0] & (1 << 5)) != 0;
    from067_5to090_0degrees = (decodedBits[0] & (1 << 4)) != 0;

    from090_0to112_5degrees = (decodedBits[0] & (1 << 3)) != 0;
    from112_5to135_0degrees = (decodedBits[0] & (1 << 2)) != 0;
    from135_0to157_5degrees = (decodedBits[0] & (1 << 1)) != 0;
    from157_5to180_0degrees = (decodedBits[0] & (1 << 0)) != 0;

    from180_0to202_5degrees = (decodedBits[1] & (1 << 7)) != 0;
    from202_5to225_0degrees = (decodedBits[1] & (1 << 6)) != 0;
    from225_0to247_5degrees = (decodedBits[1] & (1 << 5)) != 0;
    from247_5to270_0degrees = (decodedBits[1] & (1 << 4)) != 0;

    from270_0to292_5degrees = (decodedBits[1] & (1 << 3)) != 0;
    from292_5to315_0degrees = (decodedBits[1] & (1 << 2)) != 0;
    from315_0to337_5degrees = (decodedBits[1] & (1 << 1)) != 0;
    from337_5to360_0degrees = (decodedBits[1] & (1 << 0)) != 0;
  }

  void printHeadingSlice(){
    print("from000_0to022_5degrees: $from000_0to022_5degrees");
    print("from022_5to045_0degrees: $from022_5to045_0degrees");
    print("from045_0to067_5degrees: $from045_0to067_5degrees");
    print("from067_5to090_0degrees: $from067_5to090_0degrees");
    print("from090_0to112_5degrees: $from090_0to112_5degrees");
    print("from112_5to135_0degrees: $from112_5to135_0degrees");
    print("from135_0to157_5degrees: $from135_0to157_5degrees");
    print("from157_5to180_0degrees: $from157_5to180_0degrees");
    print("from180_0to202_5degrees: $from180_0to202_5degrees");
    print("from202_5to225_0degrees: $from202_5to225_0degrees");
    print("from225_0to247_5degrees: $from225_0to247_5degrees");
    print("from247_5to270_0degrees: $from247_5to270_0degrees");
    print("from270_0to292_5degrees: $from270_0to292_5degrees");
    print("from292_5to315_0degrees: $from292_5to315_0degrees");
    print("from315_0to337_5degrees: $from315_0to337_5degrees");
    print("from337_5to360_0degrees: $from337_5to360_0degrees");
  }
}