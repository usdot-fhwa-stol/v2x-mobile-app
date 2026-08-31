
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

import 'package:toastification/toastification.dart';

class IMUController extends GetxController {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);

  Rx<UserAccelerometerEvent>? _userAccelerometerEvent;
  Rx<AccelerometerEvent>? _accelerometerEvent;
  Rx<GyroscopeEvent>? _gyroscopeEvent;
  Rx<MagnetometerEvent>? _magnetometerEvent;
  Rx<BarometerEvent>? _barometerEvent;

  RxString userAccelerometerDisplay = ''.obs;
  RxString accelerometerDisplay = ''.obs;
  RxString gyroscopeDisplay = ''.obs;

  double? userAccX;
  double? userAccY;
  double? userAccZ;
  double? gyroX;
  double? gyroY;
  double? gyroZ;

  DateTime? _userAccelerometerUpdateTime;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  DateTime? _barometerUpdateTime;

  int? _userAccelerometerLastInterval;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  int? _magnetometerLastInterval;
  int? _barometerLastInterval;
  
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Duration sensorInterval = SensorInterval.normalInterval;

  void initialize() {
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (UserAccelerometerEvent event) {
          final now = event.timestamp;
            if (_userAccelerometerEvent == null) {
              _userAccelerometerEvent = Rx(event);
            } else {
              _userAccelerometerEvent!.value = event;
            }
            userAccelerometerDisplay.value = 'User Accelerometer: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}';
            userAccX = event.x;
            userAccY = event.y;
            userAccZ = event.z;
            if (_userAccelerometerUpdateTime != null) {
              final interval = now.difference(_userAccelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _userAccelerometerLastInterval = interval.inMilliseconds;
              }
            }
          _userAccelerometerUpdateTime = now;
        },
        onError: (e) {
          toastification.show(
              context: Get.context!,
              type: ToastificationType.info,
              style: ToastificationStyle.flatColored,
              title: Text("IMU Error getting user accelerometer data: $e"),
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
              primaryColor: Theme.of(Get.context!).primaryColor,
            );
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (AccelerometerEvent event) {
          final now = DateTime.now();
            if (_accelerometerEvent == null) {
              _accelerometerEvent = Rx(event);
            } else {
              _accelerometerEvent!.value = event;
            }
            accelerometerDisplay.value = 'Accelerometer: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}';
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
              }
            }
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          toastification.show(
              context: Get.context!,
              type: ToastificationType.info,
              style: ToastificationStyle.flatColored,
              title: Text("IMU Error getting accelerometer data: $e"),
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
              primaryColor: Theme.of(Get.context!).primaryColor,
            );
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (GyroscopeEvent event) {
          final now = DateTime.now();
            if (_gyroscopeEvent == null) {
              _gyroscopeEvent = Rx(event);
            } else {
              _gyroscopeEvent!.value = event;
            }
            gyroscopeDisplay.value = 'Gyroscope: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}';
            gyroX = event.x;
            gyroY = event.y;
            gyroZ = event.z;
            if (_gyroscopeUpdateTime != null) {
              final interval = now.difference(_gyroscopeUpdateTime!);
              if (interval > _ignoreDuration) {
                _gyroscopeLastInterval = interval.inMilliseconds;
              }
            }
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          toastification.show(
              context: Get.context!,
              type: ToastificationType.info,
              style: ToastificationStyle.flatColored,
              title: Text("IMU Error getting gyroscope data: $e"),
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
              primaryColor: Theme.of(Get.context!).primaryColor,
            );
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: sensorInterval).listen(
        (MagnetometerEvent event) {
          final now = DateTime.now();
            if (_magnetometerEvent == null) {
              _magnetometerEvent = Rx(event);
            } else {
              _magnetometerEvent!.value = event;
            }
            if (_magnetometerUpdateTime != null) {
              final interval = now.difference(_magnetometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _magnetometerLastInterval = interval.inMilliseconds;
              }
            }
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          toastification.show(
              context: Get.context!,
              type: ToastificationType.info,
              style: ToastificationStyle.flatColored,
              title: Text("IMU Error getting magnetometer data: $e"),
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
              primaryColor: Theme.of(Get.context!).primaryColor,
            );
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: sensorInterval).listen(
        (BarometerEvent event) {
          final now = DateTime.now();
            if (_barometerEvent == null) {
              _barometerEvent = Rx(event);
            } else {
              _barometerEvent!.value = event;
            }
            if (_barometerUpdateTime != null) {
              final interval = now.difference(_barometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _barometerLastInterval = interval.inMilliseconds;
              }
            }
          _barometerUpdateTime = now;
        },
        onError: (e) {
          toastification.show(
              context: Get.context!,
              type: ToastificationType.info,
              style: ToastificationStyle.flatColored,
              title: Text("IMU Error getting barometer data: $e"),
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 5),
              showProgressBar: false,
              dragToClose: true,
              primaryColor: Theme.of(Get.context!).primaryColor,
            );
        },
        cancelOnError: true,
      ),
    );
  }
}