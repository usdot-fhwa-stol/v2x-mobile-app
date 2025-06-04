import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class LaneSharing {
  late bool overlappingLaneDescriptionProvided;
  late bool multipleLanesTreatedAsOneLane;
  late bool otherNonMotorizedTrafficTypes;
  late bool individualMotorizedVehicleTraffic;
  late bool busVehicleTraffic;
  late bool taxiVehicleTraffic;
  late bool pedestriansTraffic;
  late bool cyclistVehicleTraffic;
  late bool trackedVehicleTraffic;
  late bool reserved;

  LaneSharing.fromBitString(C.BIT_STRING_s bits){
    List<int> decodedBits = bits.buf.asTypedList(bits.size);

    overlappingLaneDescriptionProvided = (decodedBits[0] & (1 << 7)) != 0;
    multipleLanesTreatedAsOneLane = (decodedBits[0] & (1 << 6)) != 0;
    otherNonMotorizedTrafficTypes = (decodedBits[0] & (1 << 5)) != 0;
    individualMotorizedVehicleTraffic = (decodedBits[0] & (1 << 4)) != 0;
    busVehicleTraffic = (decodedBits[0] & (1 << 3)) != 0;
    taxiVehicleTraffic = (decodedBits[0] & (1 << 2)) != 0;
    pedestriansTraffic = (decodedBits[0] & (1 << 1)) != 0;
    cyclistVehicleTraffic = (decodedBits[0] & (1 << 0)) != 0;
    trackedVehicleTraffic = (decodedBits[1] & (1 << 1)) != 0;
    reserved = (decodedBits[1] & (1 << 0)) != 0;
  }
}