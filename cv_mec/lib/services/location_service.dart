import 'dart:async';
import 'dart:io';

import 'package:cv_mec/models/position_with_declination.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cv_mec/models/declination_data.dart';
import 'package:cv_mec/services/mock_location_service.dart';
import 'package:cv_mec/services/noaa_geomag_api.dart';
import 'package:logger/logger.dart';

class LocationService extends GetxService {
  // Static variables
  final Logger _logger = Logger();
  static final MockLocationService _mockLocationService = MockLocationService();
  LocationSettings _locationSettings =
      const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 0);

  // Variables
  bool _serviceEnabled = false;
  bool _serviceMocked = false;
  StreamSubscription<Position>? _mockedStreamListener;
  late LocationPermission _permission;
  StreamSubscription<Position>? _positionStream;
  DeclinationData? _declinationData;

  // Location Stream
  final StreamController<Position> _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;

  // LocationWithDeclination Stream
  bool declinationRequestOut = false;
  Stream<PositionWithDeclination> get locationWithDeclinationStream => locationStream.map((p) {
        double? declination = getDeclination();
        if (declination == null && !declinationRequestOut) {
          declinationRequestOut = true;
          updateDeclination(p).then((v) {
            declinationRequestOut = false;
          });
        }
        return PositionWithDeclination(p, getDeclination());
      });

  LocationService() {
    if (Platform.isAndroid) {
      _locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 1),
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        // foregroundNotificationConfig: const ForegroundNotificationConfig(
        //   notificationText:
        //   "Example app will continue to receive your location even when you aren't using it",
        //   notificationTitle: "Running in Background",
        //   enableWakeLock: true,
        // )
      );
    }
    //_start(mocked, latitude, longitude, mockedLocation);
  }

  Future<void> init({bool mocked = false, double latitude = 0, double longitude = 0, Position? mockedLocation}) async {
    await _start(mocked, latitude, longitude, mockedLocation);
  }

  Future<void> _start(bool mocked, double latitude, double longitude, Position? mockedLocation) async {
    _serviceMocked = mocked;
    if (_serviceMocked) {
      _mockedStreamListener?.cancel();
      _mockedStreamListener = _mockLocationService.locationStream.listen((event) => _locationController.add(event));
      return _mockLocationService.start(latitude, longitude, mockedLocation: mockedLocation);
    }
    // This method starts the location stream. This can be called multiple times, but only one stream will be active at a time.
    try {
      await requestPermission();
      if (await isPermissionGranted() && _serviceEnabled) {
        _startLocationUpdates();
      }
    } catch (e) {
      _stopLocationUpdates();
      Get.dialog(
        AlertDialog(
          title: const Text('Location Permissions Required'),
          content: Text(
              'Location permissions are required to use this application. Without them, timing and other components will not work correctly. Please restart this application and grant location permissions. Error: $e'),
          actions: <Widget>[
            TextButton(
              child: Text('Continue', style: TextStyle(color: Theme.of(Get.context!).colorScheme.onPrimary)),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<bool> isPermissionGranted({check = false}) async {
    if (check) _permission = await Geolocator.checkPermission();
    switch (_permission) {
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
        return false;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return true;
      case LocationPermission.unableToDetermine:
        return false;
    }
  }

  Future<bool> requestPermission() async {
    print("request permission");
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _logger.w("Location services are disabled");
      return Future.error('Location services are disabled.');
    }
    print("location services ENABLED");
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      await Get.dialog(
        AlertDialog(
          title: const Text('Location Permissions'),
          content: const Text(
              'This application requires location permissions for accurate timing and data collection. Without it, timing and other components will not work correctly.'),
          actions: <Widget>[
            TextButton(
              child: Text('Continue', style: TextStyle(color: Theme.of(Get.context!).colorScheme.onPrimary)),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _logger.w("Location permissions are denied after requesting");
        return Future.error('Location permissions are denied');
      }
    }
    if (_permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _logger.w("Location permissions are permanently denied, we cannot request permissions.");
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    return true;
  }

  void _startLocationUpdates() {
    if (_serviceMocked) {
      return _mockLocationService.startMockLocationUpdates();
    }
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    _locationController.add(position);
  }

  Future<DeclinationData?> updateDeclination(Position position) async {
    _declinationData = await NoaaGeomagApi.getCurrentDeclination(position);
    return _declinationData;
  }

  void _stopLocationUpdates() {
    if (_serviceMocked) {
      return _mockLocationService.stopMockLocationUpdates();
    }
    _positionStream?.cancel();
  }

  bool mockLocationActive() {
    return _serviceMocked;
  }

  Future<Position?> getCurrentLocation() async {
    if (_serviceMocked) {
      return _mockLocationService.getCurrentLocation();
    }
    if (!await isPermissionGranted()) {
      _logger.w("Location permissions not granted, cannot get current location");
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  bool areLocationUpdatesActive() {
    if (_serviceMocked) {
      return _mockLocationService.areLocationUpdatesActive();
    }
    // if isPaused, return false
    // if null, return false
    // if non-null and not isPaused, return true
    return _serviceEnabled && !(_positionStream?.isPaused ?? true);
  }

  DeclinationData? getDeclinationData() {
    return _declinationData;
  }

  double? getDeclination() {
    return _declinationData?.result.elementAtOrNull(0)?.declination;
  }
}
