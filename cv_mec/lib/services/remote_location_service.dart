import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/augmented_position.dart';
import 'package:cv_mec/models/gps_status.dart';
import 'package:cv_mec/models/gps_type.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class RemoteLocationService extends GetxController {
  SettingsController settingsController = Get.find<SettingsController>();
  LoggingService loggingService = Get.find<LoggingService>();
  Timing timingService = Get.find<Timing>();

  Position? remotePosition;

  /// Get the position stream for remote GPS tracking
  /// Creates a new stream instance to support multiple subscriptions across navigation
  Stream<AugmentedPosition> get positionStream {
    return _createPositionStream();
  }

  /// Create the position stream from remote BSM messages
  Stream<AugmentedPosition> _createPositionStream() {
    Duration delay = Duration(milliseconds: (1000 / settingsController.broadcastRate.value).toInt());

    return Stream.periodic(delay)
        .asyncMap((_) async {
          // Return the last known position from remote device
          // If no position has been received yet, return the default position
          if (remotePosition != null) {
            return AugmentedPosition(
              latitude: remotePosition!.latitude,
              longitude: remotePosition!.longitude,
              altitude: remotePosition!.altitude,
              speed: remotePosition!.speed,
              heading: remotePosition!.heading,
              timestamp: timingService.getTime(),
              accuracy: remotePosition!.accuracy,
              altitudeAccuracy: remotePosition!.altitudeAccuracy,
              headingAccuracy: remotePosition!.headingAccuracy,
              speedAccuracy: remotePosition!.speedAccuracy,
              gpsType: GPSType.remote,
              gpsStatus: GPSStatus.normal,
            );
          } else {
            // Use default position from settings
            return AugmentedPosition(
              latitude: settingsController.remoteGPSDefaultLatitude.value,
              longitude: settingsController.remoteGPSDefaultLongitude.value,
              altitude: 0.0,
              speed: 0.0,
              heading: 0.0,
              timestamp: timingService.getTime(),
              accuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
              speedAccuracy: 0.0,
              gpsType: GPSType.remote,
              gpsStatus: GPSStatus.normal,
            );
          }
        });
  }

  /// Update the remote position with data from a received message
  void updateRemotePosition(Position newRemotePosition) {
    remotePosition = newRemotePosition;
  }
}
