// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle()
  ..name = json['name'] as String
  ..classification = $enumDecode(_$VehicleTypeEnumMap, json['classification'])
  ..color = json['color'] as String
  ..length = (json['length'] as num).toInt()
  ..width = (json['width'] as num).toInt();

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'name': instance.name,
      'classification': _$VehicleTypeEnumMap[instance.classification]!,
      'color': instance.color,
      'length': instance.length,
      'width': instance.width,
    };

const _$VehicleTypeEnumMap = {
  VehicleType.PASSENGER_VEHICLE: 'PASSENGER_VEHICLE',
  VehicleType.LIGHT_TRUCK: 'LIGHT_TRUCK',
  VehicleType.TRUCK: 'TRUCK',
  VehicleType.MOTORCYCLE: 'MOTORCYCLE',
  VehicleType.BUS: 'BUS',
  VehicleType.FIRE: 'FIRE',
  VehicleType.POLICE: 'POLICE',
  VehicleType.AMBULANCE: 'AMBULANCE',
  VehicleType.OTHER: 'OTHER',
};
