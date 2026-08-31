enum ImuSensorType {
  rotationVector(11),
  gameRotationVector(15),
  geomagneticRotationVector(20),
  gravity(9),
  linearAcceleration(10),
  gyroscope(4);

  const ImuSensorType(this.androidType);

  final int androidType;

  static ImuSensorType? fromAndroidType(int sensorType) {
    for (final type in ImuSensorType.values) {
      if (type.androidType == sensorType) {
        return type;
      }
    }
    return null;
  }
}

class ImuEvent {
  ImuEvent({
    required this.sensorType,
    required this.androidSensorType,
    required this.values,
    required this.accuracy,
    required this.timestampNanos,
    this.sensorName,
    this.yawDeg,
    this.pitchDeg,
    this.rollDeg,
  });

  final ImuSensorType? sensorType;
  final int androidSensorType;
  final List<double> values;
  final int accuracy;
  final int timestampNanos;
  final String? sensorName;
  final double? yawDeg;
  final double? pitchDeg;
  final double? rollDeg;

  double? get x => values.isNotEmpty ? values[0] : null;
  double? get y => values.length > 1 ? values[1] : null;
  double? get z => values.length > 2 ? values[2] : null;

  factory ImuEvent.fromMap(Map<dynamic, dynamic> map) {
    final int sensorType = (map['sensorType'] as num).toInt();
    final List<dynamic> rawValues = (map['values'] as List<dynamic>? ?? <dynamic>[]);
    return ImuEvent(
      sensorType: ImuSensorType.fromAndroidType(sensorType),
      androidSensorType: sensorType,
      values: rawValues.map((dynamic value) => (value as num).toDouble()).toList(growable: false),
      accuracy: ((map['accuracy'] as num?) ?? 0).toInt(),
      timestampNanos: ((map['timestampNanos'] as num?) ?? 0).toInt(),
      sensorName: map['sensorName'] as String?,
      yawDeg: (map['yawDeg'] as num?)?.toDouble(),
      pitchDeg: (map['pitchDeg'] as num?)?.toDouble(),
      rollDeg: (map['rollDeg'] as num?)?.toDouble(),
    );
  }
}
