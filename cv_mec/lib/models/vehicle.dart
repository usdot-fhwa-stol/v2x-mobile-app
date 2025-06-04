// ignore: depend_on_referenced_packages
import 'package:asn1_plugin/j2735/2024/common/basic_vehicle_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  late String name;
  late VehicleType classification;
  late String color;
  late int length;
  late int width;

  Vehicle() {
    name = "";
    classification = VehicleType.PASSENGER_VEHICLE;
    color = "";
    length = 0;
    width = 0;
  }

  Vehicle.detailed(this.name, this.classification, this.color, this.length, this.width);

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}

enum VehicleType {
  @JsonValue('PASSENGER_VEHICLE')
  PASSENGER_VEHICLE(0),
  @JsonValue('LIGHT_TRUCK')
  LIGHT_TRUCK(1),
  @JsonValue('TRUCK')
  TRUCK(2),
  @JsonValue('MOTORCYCLE')
  MOTORCYCLE(3),
  @JsonValue('BUS')
  BUS(4),
  @JsonValue('FIRE')
  FIRE(5),
  @JsonValue('POLICE')
  POLICE(6),
  @JsonValue('AMBULANCE')
  AMBULANCE(7),
  @JsonValue('OTHER')
  OTHER(8);

  final int code;
  const VehicleType(this.code);

  static VehicleType fromVehicleClass(VehicleClass code) {
    if (code.code <= 11) {
      return VehicleType.PASSENGER_VEHICLE;
    } else if (code.code >= 20 && code.code <= 21) {
      return VehicleType.LIGHT_TRUCK;
    } else if (code.code >= 25 && code.code <= 35) {
      return VehicleType.TRUCK;
    } else if (code.code >= 40 && code.code <= 48) {
      return VehicleType.MOTORCYCLE;
    } else if (code.code >= 50 && code.code <= 58) {
      return VehicleType.BUS;
    } else if (code.code >= 62 && code.code <= 65) {
      return VehicleType.FIRE;
    } else if (code.code >= 66 && code.code <= 67) {
      return VehicleType.POLICE;
    } else if (code.code == 69) {
      return VehicleType.AMBULANCE;
    } else if (code.code >= 80 && code.code <= 86) {
      return VehicleType.OTHER;
    } else {
      return VehicleType.PASSENGER_VEHICLE;
    }
  }

  static VehicleClass toVehicleClass(VehicleType type) {
    if (type == VehicleType.PASSENGER_VEHICLE) {
      return VehicleClass.passengerVehicleTypeUnknown;
    } else if (type == VehicleType.LIGHT_TRUCK) {
      return VehicleClass.lightTruckVehicleTypeUnknown;
    } else if (type == VehicleType.TRUCK) {
      return VehicleClass.truckVehicleTypeUnknown;
    } else if (type == VehicleType.MOTORCYCLE) {
      return VehicleClass.motorcycleTypeUnknown;
    } else if (type == VehicleType.BUS) {
      return VehicleClass.transitTypeUnknown;
    } else if (type == VehicleType.FIRE) {
      return VehicleClass.emergencyFireLightVehicle;
    } else if (type == VehicleType.POLICE) {
      return VehicleClass.emergencyPoliceLightVehicle;
    } else if (type == VehicleType.AMBULANCE) {
      return VehicleClass.emergencyOtherAmbulance;
    } else if (type == VehicleType.OTHER) {
      return VehicleClass.otherTravelerTypeUnknown;
    }
    return VehicleClass.passengerVehicleTypeUnknown;
  }
}
