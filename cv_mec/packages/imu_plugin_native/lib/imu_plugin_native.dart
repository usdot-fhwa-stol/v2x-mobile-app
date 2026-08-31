library imu_plugin_native;

import 'src/imu_event.dart';
import 'src/imu_plugin_native_method_channel.dart';

export 'src/imu_event.dart';

class ImuPluginNative {
  ImuPluginNative._();

  static final ImuPluginNativeMethodChannel _channel = ImuPluginNativeMethodChannel();

  static Stream<ImuEvent> get events => _channel.eventStream;

  static Stream<ImuEvent> eventsForType(ImuSensorType type) {
    return events.where((ImuEvent event) => event.sensorType == type);
  }

  static Future<bool> initialize() {
    return _channel.initialize();
  }

  static Future<bool> startStreaming() {
    return _channel.startStreaming();
  }

  static Future<bool> stopStreaming() {
    return _channel.stopStreaming();
  }

  static Future<bool> setSamplingPeriodUs(int samplingPeriodUs) {
    return _channel.setSamplingPeriodUs(samplingPeriodUs);
  }

  static Future<Map<String, bool>> getAvailabilityMap() {
    return _channel.getAvailabilityMap();
  }
}
