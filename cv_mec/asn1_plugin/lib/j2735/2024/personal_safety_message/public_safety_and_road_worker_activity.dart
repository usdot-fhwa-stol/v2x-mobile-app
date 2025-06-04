import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class PublicSafetyAndRoadWorkerActivity {
  late bool unavailable;
  late bool workingOnRoad;
  late bool settingUpClosures;
  late bool respondingToEvents;
  late bool directingTraffic;
  late bool otherActivities;


  PublicSafetyAndRoadWorkerActivity.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailable = (decodedBits[0] & (1 << 7)) != 0;
    workingOnRoad = (decodedBits[0] & (1 << 6)) != 0;
    settingUpClosures = (decodedBits[0] & (1 << 5)) != 0;
    respondingToEvents = (decodedBits[0] & (1 << 4)) != 0;
    directingTraffic = (decodedBits[0] & (1 << 3)) != 0;
    otherActivities = (decodedBits[0] & (1 << 2)) != 0;
  }
}