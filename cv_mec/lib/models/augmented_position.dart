import 'package:cv_mec/models/gps_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cv_mec/models/gps_status.dart';

class AugmentedPosition extends Position{

  final GPSType gpsType;
  final GPSStatus gpsStatus;
  
  AugmentedPosition({
    required super.longitude,
    required super.latitude,
    required super.timestamp,
    required super.accuracy,
    required super.altitude,
    required super.altitudeAccuracy,
    required super.heading,
    required super.headingAccuracy,
    required super.speed,
    required super.speedAccuracy,
    super.floor,
    super.isMocked = false,
    this.gpsType = GPSType.unknown,
    this.gpsStatus = GPSStatus.simulated
  });

  AugmentedPosition.fromPosition(Position position, this.gpsType, this.gpsStatus): super(
    longitude: position.longitude,
    latitude: position.latitude,
    timestamp: position.timestamp,
    accuracy: position.accuracy,
    altitude: position.altitude,
    altitudeAccuracy: position.altitudeAccuracy,
    heading: position.heading,
    headingAccuracy: position.headingAccuracy,
    speed: position.speed,
    speedAccuracy: position.speedAccuracy,
    floor: position.floor,
    isMocked: position.isMocked
  );

  AugmentedPosition copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    double? speedAccuracy,
    int? floor,
    double? altitudeAccuracy,
    double? headingAccuracy,
    bool? isMocked,
    GPSType? gpsType,
    GPSStatus? gpsStatus,
  }) {
    return AugmentedPosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
      floor: floor ?? this.floor,
      altitudeAccuracy: altitudeAccuracy ?? this.altitudeAccuracy,
      headingAccuracy: headingAccuracy ?? this.headingAccuracy,
      isMocked: isMocked ?? this.isMocked,
      gpsType: gpsType ?? this.gpsType,
      gpsStatus: gpsStatus ?? this.gpsStatus,
    );
  }
  

  

}