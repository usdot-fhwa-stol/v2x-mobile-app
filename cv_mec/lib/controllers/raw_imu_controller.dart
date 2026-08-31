
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';

import 'package:imu_plugin_native/imu_plugin_native.dart';
import 'package:toastification/toastification.dart';

typedef ImuEventReceivedCallback = void Function(ImuEvent event, DateTime receivedAt);

class RawIMUController extends GetxController {
  RxString rotationVectorDisplay = ''.obs;
  RxString gameRotationVectorDisplay = ''.obs;
  RxString geomagneticRotationVectorDisplay = ''.obs;
  RxString gravityDisplay = ''.obs;
  RxString linearAccelerationDisplay = ''.obs;
  RxString gyroscopeDisplay = ''.obs;
  RxMap<String, bool> sensorAvailability = <String, bool>{}.obs;

  double? rotationVectorX;
  double? rotationVectorY;
  double? rotationVectorZ;
  RxDouble rotationVectorYawDeg = 0.0.obs;
  RxDouble rotationVectorPitchDeg = 0.0.obs;
  RxDouble rotationVectorRollDeg = 0.0.obs;

  double? gameRotationVectorX;
  double? gameRotationVectorY;
  double? gameRotationVectorZ;
  RxDouble gameRotationVectorYawDeg = 0.0.obs;
  RxDouble gameRotationVectorPitchDeg = 0.0.obs;
  RxDouble gameRotationVectorRollDeg = 0.0.obs;

  double? linearAccelerationX;
  double? linearAccelerationY;
  double? linearAccelerationZ;

  double? gyroscopeXRadPerSec;
  double? gyroscopeYRadPerSec;
  double? gyroscopeZRadPerSec;

  ImuEventReceivedCallback? onImuEventReceived;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      return;
    }

    final bool initialized = await ImuPluginNative.initialize();
    if (!initialized) {
      _showInfoToast('Native IMU plugin failed to initialize.');
      return;
    }

    sensorAvailability.assignAll(await ImuPluginNative.getAvailabilityMap());
    await ImuPluginNative.setSamplingPeriodUs(20 * 1000);

    _streamSubscriptions.add(
      ImuPluginNative.events.listen(
        _handleImuEvent,
        onError: (Object error) {
          _showInfoToast('IMU native stream error: $error');
        },
        cancelOnError: false,
      ),
    );

    final bool started = await ImuPluginNative.startStreaming();
    if (!started) {
      _showInfoToast('No requested native IMU sensors are available for streaming.');
      for (final subscription in _streamSubscriptions) {
        subscription.cancel();
      }
      _streamSubscriptions.clear();
      return;
    }
  }

  @override
  void onClose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();

    if (Platform.isAndroid) {
      ImuPluginNative.stopStreaming();
    }
    super.onClose();
  }

  void _handleImuEvent(ImuEvent event) {
    onImuEventReceived?.call(event, DateTime.now());
    final String sensorName = event.sensorName ?? event.androidSensorType.toString();

    switch (event.sensorType) {
      case ImuSensorType.rotationVector:
        rotationVectorX = event.x;
        rotationVectorY = event.y;
        rotationVectorZ = event.z;
        rotationVectorYawDeg.value = event.yawDeg ?? 0.0;
        rotationVectorPitchDeg.value = event.pitchDeg ?? 0.0;
        rotationVectorRollDeg.value = event.rollDeg ?? 0.0;
        rotationVectorDisplay.value =
            '$sensorName xyz=[${_fmt(event.x)}, ${_fmt(event.y)}, ${_fmt(event.z)}] '
            'ypr=[${_fmt(event.yawDeg)}, ${_fmt(event.pitchDeg)}, ${_fmt(event.rollDeg)}]';
        break;
      case ImuSensorType.gameRotationVector:
        gameRotationVectorX = event.x;
        gameRotationVectorY = event.y;
        gameRotationVectorZ = event.z;
        gameRotationVectorYawDeg.value = event.yawDeg ?? 0.0;
        gameRotationVectorPitchDeg.value = event.pitchDeg ?? 0.0;
        gameRotationVectorRollDeg.value = event.rollDeg ?? 0.0;
        gameRotationVectorDisplay.value =
            '$sensorName xyz=[${_fmt(event.x)}, ${_fmt(event.y)}, ${_fmt(event.z)}] '
            'ypr=[${_fmt(event.yawDeg)}, ${_fmt(event.pitchDeg)}, ${_fmt(event.rollDeg)}]';
        break;
      case ImuSensorType.geomagneticRotationVector:
        geomagneticRotationVectorDisplay.value =
            '$sensorName xyz=[${_fmt(event.x)}, ${_fmt(event.y)}, ${_fmt(event.z)}] '
            'ypr=[${_fmt(event.yawDeg)}, ${_fmt(event.pitchDeg)}, ${_fmt(event.rollDeg)}]';
        break;
      case ImuSensorType.gravity:
        gravityDisplay.value =
            '$sensorName xyz=[${_fmt(event.x)}, ${_fmt(event.y)}, ${_fmt(event.z)}]';
        break;
      case ImuSensorType.linearAcceleration:
        linearAccelerationX = event.x;
        linearAccelerationY = event.y;
        linearAccelerationZ = event.z;
        linearAccelerationDisplay.value =
            '$sensorName xyz=[${_fmt(event.x)}, ${_fmt(event.y)}, ${_fmt(event.z)}]';
        break;
      case ImuSensorType.gyroscope:
        gyroscopeXRadPerSec = event.x;
        gyroscopeYRadPerSec = event.y;
        gyroscopeZRadPerSec = event.z;
        gyroscopeDisplay.value =
            '$sensorName rad/s xyz=[${_fmt(event.x)}, ${_fmt(event.y)}, ${_fmt(event.z)}]';
        break;
      case null:
        break;
    }
  }

  String _fmt(double? value) {
    if (value == null) {
      return 'n/a';
    }
    return value.toStringAsFixed(3);
  }

  void _showInfoToast(String text) {
    final context = Get.context;
    if (context == null) {
      return;
    }
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(text),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
      dragToClose: true,
      primaryColor: Theme.of(context).primaryColor,
    );
  }
}