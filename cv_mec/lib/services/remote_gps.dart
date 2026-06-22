import 'dart:io';
import 'dart:convert';

import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/models/etx/registration.dart';
import 'package:cv_mec/pages/settings_page.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:geolocator/geolocator.dart';

class RemoteGPSService extends GetxController {
  //final String baseURI = "http://cvmecapidns.eastus.azurecontainer.io:8080"; //SETTINGS Configuration
  SettingsController settingsController = Get.find<SettingsController>();
  LoggingService loggingService = Get.find<LoggingService>();

  IOClient _createInsecureClient() {
    final httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  Future getToken() async {
    final uri = Uri.https(settingsController.cradleGPSIP.value, '/api/v1/auth/tokens');
    final client = _createInsecureClient();

    final response = await client.post(
      uri,
      headers: {
        'accept': 'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json',
      },
      body:
          jsonEncode({'login': settingsController.cradleGPSUsername.value, 'password': settingsController.cradleGPSPassword.value}),
    );

    if (response.statusCode != 200) {
      throw HttpException('Auth failed (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['data']['access_token'] as String;

    return {
      'accept': 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getInfo(Map<String, String> headers) async {
    final uri = Uri.https(settingsController.cradleGPSIP.value, '/api/v1/db/get');
    final client = _createInsecureClient();

    final payload = [
      {
        'fields': [
          'location.gnss.longitude',
          'location.gnss.latitude',
          'location.gnss.altitude',
          'location.gnss.speed',
          'location.gnss.heading',
          'net.interface.cellular[c1].technology.current',
          'net.interface.cellular[c1].snr',
        ]
      }
    ];

    final response = await client.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw HttpException('DB query failed (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return Map<String, dynamic>.from(data.first as Map);
  }

  Stream<Position> positionStream({
    Duration interval = const Duration(seconds: 1),
  }) {
    return Stream.periodic(interval)
        .asyncMap((_) async {
          try {
            final headers = await getToken();
            final info = await getInfo(headers);

            return Position(
              latitude: (info['location.gnss.latitude'] as num).toDouble(),
              longitude: (info['location.gnss.longitude'] as num).toDouble(),
              altitude: (info['location.gnss.altitude'] as num).toDouble(),
              speed: ((info['location.gnss.speed'] as num).toDouble()) / 3.6, //converting kmh to m/s
              heading: (info['location.gnss.heading'] as num).toDouble(),
              timestamp: DateTime.now(),
              accuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
              speedAccuracy: 0,
            );
          } catch (e) {
            loggingService.showError('RemoteGPSService error: $e');
            return null;
          }
        })
        // drop any nulls that came from errors
        .where((pos) => pos != null)
        // cast back to non-nullable
        .cast<Position>();
  }
}
