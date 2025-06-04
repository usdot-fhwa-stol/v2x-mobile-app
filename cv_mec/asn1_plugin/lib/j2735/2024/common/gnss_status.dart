import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class GNSSstatus {
  late bool unavailable;
  late bool isHealthy;
  late bool isMonitored;
  late bool baseStationType;
  late bool aPDOPofUnder5;
  late bool inViewOfUnder5;
  late bool localCorrectionsPresent;
  late bool networkCorrectionsPresent;


  GNSSstatus.fromBitString(C.BIT_STRING_s bits){

    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailable = (decodedBits[0] & (1 << 7)) != 0;
    isHealthy = (decodedBits[0] & (1 << 6)) != 0;
    isMonitored = (decodedBits[0] & (1 << 5)) != 0;
    baseStationType = (decodedBits[0] & (1 << 4)) != 0;

    aPDOPofUnder5 = (decodedBits[0] & (1 << 3)) != 0;
    inViewOfUnder5 = (decodedBits[0] & (1 << 2)) != 0;
    localCorrectionsPresent = (decodedBits[0] & (1 << 1)) != 0;
    networkCorrectionsPresent = (decodedBits[0] & (1 << 0)) != 0;

  }
}