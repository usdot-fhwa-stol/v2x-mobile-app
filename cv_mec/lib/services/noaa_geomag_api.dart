import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cv_mec/models/declination_data.dart';
import 'package:cv_mec/services/logging_service.dart';

// Documentation: https://www.ngdc.noaa.gov/geomag/CalcSurveyFin.shtml
class NoaaGeomagApi {
  static final LoggingService loggingService = LoggingService();
  static final String _apiKey = dotenv.env['NOAA_GEOMAG_API_TOKEN']!;
  static const String _baseUrl =
      'https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1={LATITUDE}&lon1={LONGITUDE}&key={API_KEY}&resultFormat=json';

  static Future<DeclinationData?> getCurrentDeclination(
      Position position) async {
    final url = _baseUrl
        .replaceAll('{LATITUDE}', position.latitude.toString())
        .replaceAll('{LONGITUDE}', position.longitude.toString())
        .replaceAll('{API_KEY}', _apiKey);
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      // Make the API call and return the response
      var response = await http.get(Uri.parse(url), headers: headers).timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response('Timeout', 408),
          );
      switch (response.statusCode) {
        case 401:
        case 403:
          loggingService.showError("Invalid API key");
          return null;
        case 408:
          loggingService.showError("Timeout, request timed out");
          return null;
        default:
          return DeclinationData.fromJson(json.decode(response.body));
      }
    } on SocketException catch (_) {
      loggingService.showError("Socket Exception in getDeclination");
      return null;
    }
  }
}
