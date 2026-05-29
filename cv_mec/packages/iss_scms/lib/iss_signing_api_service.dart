import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iss_scms/models/expiration_information.dart';
import 'package:iss_scms/models/signing_api_state.dart';
import 'package:iss_scms/models/token_type.dart';
import 'package:iss_scms/models/validate_status.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// IssSigningApiService is a GetX service that provides methods to interact with an external ISS Signing API.
/// It handles health checks, message validation, digital signing, device certificate management, state queries,
/// certificate top-off, and cache clearing. This service is currently used by Linux users.

class IssSigningApiService extends GetxService {
  final Logger _logger = Logger();
  String baseUrl = dotenv.env['LINUX_ISS_SIGNING_URL'] ?? "";


  Future<String?> getHealth() async {
    String uri = "$baseUrl/health";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    try {
      var response = await http.get(Uri.parse(uri), headers: headers);
      if (response.statusCode == 200) {
        return response.body.toString();
      }else{
        _logger.e("Error doing health check: ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      _logger.e("Error doing health check: $e");
      return null;
    }
    return null;
  }

  Future<ValidateStatus> validate(List<int> bytes) async {
    String uri = "$baseUrl/validate";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    String body = jsonEncode({
      "messageHex": bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      "shouldValidate": true
    });
    try {
      var response = await http.post(Uri.parse(uri), headers: headers, body: body);
      if (response.statusCode == 200) {
        return enumFromString(response.body.toString(), ValidateStatus.values, ValidateStatus.FAILURE);
      }else{
        _logger.e("Error validating: ${response.statusCode} ${response.body.toString()}");
        return ValidateStatus.FAILURE;
      }
    } catch (e) {
      _logger.e("Error validating: $e");
      return ValidateStatus.FAILURE;
    }
  }

  Future<List<int>?> sign(int psid, List<int> tbsOer, int? jIndex, bool? digestSigner) async {
    String uri = "$baseUrl/sign";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    String body = jsonEncode({ 
      "psid": psid,
      "tbsOerHex": bytesToHex(tbsOer),
      "jIndex": jIndex,
      "digestSigner": digestSigner
    });
    try {
      var response = await http.post(Uri.parse(uri), headers: headers, body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        String signedList = json['signedMessageHex'];
        return hexToBytes(signedList);
      }else{
        _logger.e("Error signing: ${response.statusCode} ${response.body.toString()}");
        return null;
      }
    } catch (e) {
      _logger.e("Error signing: $e");
      return null;
    }
  }

  Future<void> getDeviceCerts(String token, TokenType tokenType, String deviceId) async {
    String uri = "$baseUrl/get-device-certs";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    String body = jsonEncode({
      "token": token,
      "tokenType": tokenType.name.toLowerCase().replaceAll("_", "-"),
      "deviceId": deviceId
    });
    try {
      var response = await http.post(Uri.parse(uri), headers: headers, body: body);
      if (response.statusCode == 200) {
        _logger.i("Device Certs sent successfully");
      }else{
        _logger.e("Error getting device certs: ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      _logger.e("Error doing health check: $e");
    }
  }

  Future<SigningApiState> getState() async {
    String uri = "$baseUrl/state";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    try {
      var response = await http.get(Uri.parse(uri), headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        return enumFromString(json['state'], SigningApiState.values, SigningApiState.NEED_CERTS);
      }else{
        _logger.e("Error getting state: ${response.statusCode} ${response.body.toString()}");
        return SigningApiState.NEED_INIT;
      }
    } catch (e) {
      _logger.e("Error getting state: $e");
      return SigningApiState.NEED_INIT;
    }
  }

  Future<void> topOffCerts(String token, TokenType tokenType) async {
    String uri = "$baseUrl/top-off-certs";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    String body = jsonEncode({
      "token": token,
      "tokenType": tokenType.index
    });
    try {
      var response = await http.post(Uri.parse(uri), headers: headers, body: body);
      if (response.statusCode == 200) {
        _logger.i("Top off certs request sent successfully");
      }else{
        _logger.e("Error topping off certs: ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      _logger.e("Error topping off certs: $e");
    }
  }

  Future<void> clearCache(int clearBeforeUnixTimeSeconds) async {
    String uri = "$baseUrl/clear-cache";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    String body = jsonEncode({
      "clearBeforeUnixTimeSeconds": clearBeforeUnixTimeSeconds
    });
    try {
      var response = await http.post(Uri.parse(uri), headers: headers, body: body);
      if (response.statusCode == 200) {
        _logger.i("Clear cache request sent successfully");
      }else{
        _logger.e("Error clearing cache: ${response.statusCode} ${response.body.toString()}");
      }
    } catch (e) {
      _logger.e("Error clearing cache: $e");
    }
  }

  T enumFromString<T extends Enum>(String? value, List<T> values, T def) {
    try {
      return values.firstWhere((e) => e.name == value);
    } catch (_) {
      return def;
    }
  }

  static List<int> hexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      throw const FormatException('Invalid hexadecimal string');
    }
    final length = hex.length ~/ 2;
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      final hexByte = hex.substring(i * 2, i * 2 + 2);
      final byte = int.parse(hexByte, radix: 16);
      bytes[i] = byte;
    }
    return bytes.toList();
  }

  static String bytesToHex(List<int> bytes) {
    final StringBuffer buffer = StringBuffer();
    for (int byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase(); 
  }
}