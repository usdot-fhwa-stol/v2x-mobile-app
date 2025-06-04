import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class AllowedManeuvers{
  late bool maneuverStraightAllowed;
  late bool maneuverLeftAllowed;
  late bool maneuverRightAllowed;
  late bool maneuverUTurnAllowed;
  late bool maneuverLeftTurnOnRedAllowed;
  late bool maneuverRightTurnOnRedAllowed;
  late bool maneuverLaneChangeAllowed;
  late bool maneuverNoStoppingAllowed;
  late bool yieldAlwaysRequired;
  late bool goWithHalt;
  late bool caution;
  late bool reserved1;



  AllowedManeuvers.fromBitString(C.BIT_STRING_s bits){

    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    maneuverStraightAllowed = (decodedBits[0] & (1 << 7)) != 0;
    maneuverLeftAllowed = (decodedBits[0] & (1 << 6)) != 0;
    maneuverRightAllowed = (decodedBits[0] & (1 << 5)) != 0;
    maneuverUTurnAllowed = (decodedBits[0] & (1 << 4)) != 0;
    maneuverLeftTurnOnRedAllowed = (decodedBits[0] & (1 << 3)) != 0;
    maneuverRightTurnOnRedAllowed = (decodedBits[0] & (1 << 2)) != 0;
    maneuverLaneChangeAllowed = (decodedBits[0] & (1 << 1)) != 0;
    maneuverNoStoppingAllowed = (decodedBits[0] & (1 << 0)) != 0;
    yieldAlwaysRequired = (decodedBits[1] & (1 << 7)) != 0;
    goWithHalt = (decodedBits[1] & (1 << 6)) != 0;
    caution = (decodedBits[1] & (1 << 5)) != 0;
    reserved1 = (decodedBits[1] & (1 << 4)) != 0;

  }

}