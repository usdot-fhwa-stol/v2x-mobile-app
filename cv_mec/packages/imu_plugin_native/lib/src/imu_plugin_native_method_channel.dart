import 'package:flutter/services.dart';

import 'imu_event.dart';

class ImuPluginNativeMethodChannel {
  static const MethodChannel _methodChannel = MethodChannel('imu_plugin_native/methods');
  static const EventChannel _eventChannel = EventChannel('imu_plugin_native/events');

  Stream<ImuEvent>? _eventStream;

  Stream<ImuEvent> get eventStream {
    _eventStream ??= _eventChannel.receiveBroadcastStream().map((dynamic event) {
      return ImuEvent.fromMap(event as Map<dynamic, dynamic>);
    });
    return _eventStream!;
  }

  Future<bool> initialize() async {
    final bool? initialized = await _methodChannel.invokeMethod<bool>('initialize');
    return initialized ?? false;
  }

  Future<bool> startStreaming() async {
    final bool? started = await _methodChannel.invokeMethod<bool>('startStreaming');
    return started ?? false;
  }

  Future<bool> stopStreaming() async {
    final bool? stopped = await _methodChannel.invokeMethod<bool>('stopStreaming');
    return stopped ?? false;
  }

  Future<bool> setSamplingPeriodUs(int samplingPeriodUs) async {
    final bool? updated = await _methodChannel.invokeMethod<bool>('setSamplingPeriodUs', <String, dynamic>{
      'samplingPeriodUs': samplingPeriodUs,
    });
    return updated ?? false;
  }

  Future<Map<String, bool>> getAvailabilityMap() async {
    final Map<dynamic, dynamic>? map =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getAvailabilityMap');
    if (map == null) {
      return <String, bool>{};
    }
    return map.map((dynamic key, dynamic value) {
      return MapEntry(key.toString(), value == true);
    });
  }
}
