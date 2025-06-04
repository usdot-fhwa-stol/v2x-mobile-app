import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

class IntersectionStatusObject {

  late bool manualControlIsEnabled;
  late bool stopTimeIsActivated;
  late bool failureFlash;
  late bool preemptIsActive;
  late bool signalPriorityIsActive;
  late bool fixedTimeOPeration;
  late bool trafficDependentOperation;
  late bool standbyOperation;
  late bool failureMode;
  late bool off;
  late bool recentMAPmessageUpdate;
  late bool recentChangeInMAPassignedLanesIDsUsed;
  late bool noValidMAPisAvailableAtThisTime;
  late bool noValidSPATisAvailableAtThisTime;

  IntersectionStatusObject.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    manualControlIsEnabled = (decodedBits[0] & (1 << 7)) != 0;
    stopTimeIsActivated = (decodedBits[0] & (1 << 6)) != 0;
    failureFlash = (decodedBits[0] & (1 << 5)) != 0;
    preemptIsActive = (decodedBits[0] & (1 << 4)) != 0;
    signalPriorityIsActive = (decodedBits[0] & (1 << 3)) != 0;
    fixedTimeOPeration = (decodedBits[0] & (1 << 2)) != 0;
    trafficDependentOperation = (decodedBits[0] & (1 << 1)) != 0;
    standbyOperation = (decodedBits[0] & (1 << 0)) != 0;
    failureMode = (decodedBits[1] & (1 << 7)) != 0;
    off = (decodedBits[1] & (1 << 6)) != 0;
    recentMAPmessageUpdate = (decodedBits[1] & (1 << 5)) != 0;
    recentChangeInMAPassignedLanesIDsUsed = (decodedBits[1] & (1 << 4)) != 0;
    noValidMAPisAvailableAtThisTime = (decodedBits[1] & (1 << 3)) != 0;
    noValidSPATisAvailableAtThisTime = (decodedBits[1] & (1 << 2)) != 0;
  }
}