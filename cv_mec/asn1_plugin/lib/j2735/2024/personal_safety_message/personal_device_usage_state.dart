import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class PersonalDeviceUsageState {
  late bool unavailable;
  late bool other;
  late bool idle;
  late bool listeningToAudio;
  late bool typing;
  late bool calling;
  late bool playingGames;
  late bool reading;
  late bool viewing;

  PersonalDeviceUsageState.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailable = (decodedBits[0] & (1 << 7)) != 0;
    other = (decodedBits[0] & (1 << 6)) != 0;
    idle = (decodedBits[0] & (1 << 5)) != 0;
    listeningToAudio = (decodedBits[0] & (1 << 4)) != 0;

    typing = (decodedBits[0] & (1 << 3)) != 0;
    calling = (decodedBits[0] & (1 << 2)) != 0;
    playingGames = (decodedBits[0] & (1 << 1)) != 0;
    reading = (decodedBits[0] & (1 << 0)) != 0;

    viewing = (decodedBits[1] & (1 << 7)) != 0;
  }
}