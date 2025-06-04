import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class PublicSafetyDirectingTrafficSubType{
  late bool unavailable;
  late bool policeAndTrafficOfficers;
  late bool trafficControlPersons;
  late bool railroadCrossingGuards; 
  late bool civilDefenseNationalGuardMilitaryPolice;
  late bool emergencyOrganizationPersonnel;
  late bool highwayServiceVehiclePersonnel;

  PublicSafetyDirectingTrafficSubType.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    unavailable = (decodedBits[0] & (1 << 7)) != 0;
    policeAndTrafficOfficers = (decodedBits[0] & (1 << 6)) != 0;
    trafficControlPersons = (decodedBits[0] & (1 << 5)) != 0;
    railroadCrossingGuards = (decodedBits[0] & (1 << 4)) != 0;

    civilDefenseNationalGuardMilitaryPolice = (decodedBits[0] & (1 << 3)) != 0;
    emergencyOrganizationPersonnel = (decodedBits[0] & (1 << 2)) != 0;
    highwayServiceVehiclePersonnel = (decodedBits[0] & (1 << 1)) != 0;
  }


}