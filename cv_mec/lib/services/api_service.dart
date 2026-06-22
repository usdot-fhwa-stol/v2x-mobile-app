import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_mec/services/logging_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/api_responses/mqtt_permission.dart';
import 'package:cv_mec/models/api_responses/path_response/path_response.dart';
import 'package:cv_mec/models/api_responses/secrets/secret_response.dart';
import 'package:cv_mec/models/etx/full_registration.dart';
import 'package:cv_mec/models/etx/registration.dart';
import 'package:get/get.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxController {
  SettingsController settingsController = Get.find<SettingsController>();
  LoggingService loggingService = Get.find<LoggingService>();
  String? token;

  late final http.Client _client = _buildClient();

  http.Client _buildClient(){
    final ioClient = HttpClient();

    ioClient.badCertificateCallback = (X509Certificate cer, String host, int port){
      // Only allow bad certificates if explicitly enabled via environment variable
      final allowInvalidApiCertificate = (dotenv.env['ALLOW_INVALID_API_CERTIFICATE'] ?? '').toLowerCase() == 'true';
      if (!allowInvalidApiCertificate) {
        return false;
      }

      // Even when enabled, only allow for the configured API host
      final configuredHost = Uri.tryParse(settingsController.baseUri.value)?.host;
      return configuredHost != null && configuredHost == host;
    };

    return IOClient(ioClient);
  }


  Future<bool> setupToken() async {
    for(int i =0; i<3; i++){
      token = await getToken();
      if(token != null) break;
      loggingService.addToAppLog("Retrying to get API Token - Attempt ${i+1}/3");
      await Future.delayed(Duration(seconds: 3));
    }

    return token != null;
  }

  Future<String?> getToken() async {
    try {
      loggingService.addToAppLog("generating token from api");

      String uri = "${settingsController.baseUri.value}/auth/token";
      final Map<String, String> headers = {"Content-Type": "application/json", "Accept": "application/json"};

      final Map<String, String> body = {
        "username": settingsController.username.value,
        "password": settingsController.password.value,
      };

      try {
        loggingService.addToAppLog("Sending Token Request to API $uri");
        var response = await _client.post(Uri.parse(uri), headers: headers, body: json.encode(body));
        loggingService.addToAppLog("Received Response");
        if (response.statusCode == 200) {
          Map<String, dynamic> responseObject = jsonDecode(response.body.toString());
          if (responseObject.containsKey("access_token")) {
            loggingService.addToAppLog("Token Generated Successfully");
            return responseObject["access_token"];
          }else{
            loggingService.addToAppLog("Token not found in response ${response.body.toString()}");
          }
        }else{
          loggingService.showError("Error Generating Token: ${response.statusCode} ${response.body.toString()}");
        }
      } catch (e) {
        loggingService.showError("Error Generating Token: $e");
        return null;
      }

      return null;
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    }
  }

  Future<FullRegistration?> checkRegistration(String deviceID) async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Checking Device Registration");
      final String uri = "${settingsController.baseUri.value}/prd/v2/registration?DeviceID=$deviceID";
      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      var response = await _client.get(Uri.parse(uri), headers: headers);

      if (response.statusCode == 200) {
        dynamic registrationDynamic = jsonDecode(response.body.toString());

        FullRegistration registration = FullRegistration.fromJson(registrationDynamic);

        return registration;
      } else {
        loggingService.showError("Error Code ${response.statusCode} ${response.body.toString()}");
      }
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    } catch (e) {
      loggingService.showError("Unable to Register app for unknown reasons $e");
      return null;
    }
    return null;
  }


  Future getRegistration(String clientType, String clientSubtype) async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Registering Device");
      final String uri = "${settingsController.baseUri.value}/prd/v2/registration";
      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      final String body = jsonEncode({
        "ClientType": clientType,
        "ClientSubtype": clientSubtype,
      });

      var response = await _client.post(Uri.parse(uri), headers: headers, body: body);

      if (response.statusCode == 200) {
        dynamic registrationDynamic = jsonDecode(response.body.toString());

        Registration registration = Registration.fromJson(registrationDynamic);

        return registration;
      } else {
        loggingService.showError(response.body.toString());
      }
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    } catch (e) {
      loggingService.showError("Unable to Register app for unknown reasons $e");
      return null;
    }
  }

  Future updateRegistration(String deviceID) async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Updating Device Registration");
      final String uri = "${settingsController.baseUri.value}/prd/v2/registration";
      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      final String body = jsonEncode({
        "DeviceID": deviceID
      });

      var response = await _client.put(Uri.parse(uri), headers: headers, body: body);

      if (response.statusCode == 200) {
        dynamic registrationDynamic = jsonDecode(response.body.toString());

        Registration registration = Registration.fromJson(registrationDynamic);

        return registration;
      } else if (response.statusCode == 404){
        return null;
      }else {
        loggingService.showError("Error Retrieving Registration ${response.statusCode} ${response.body.toString()}");
        return null;
      }
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to update registration with API: $e");
      return null;
    } catch (e) {
      loggingService.showError("Unable to update registration for unknown reasons $e");
      return null;
    }
  }

  Future getConnection(String deviceID, double lat, double long, String networkType) async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Registering Device");
      final String uri = "${settingsController.baseUri.value}/prd/v2/connection";

      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      final String body = jsonEncode({"DeviceID": deviceID, "lat": lat, "long": long, "NetworkType": networkType});

      var response = await _client.post(Uri.parse(uri), headers: headers, body: body);

      Map<String, dynamic> json = jsonDecode(response.body.toString());
      loggingService.addToAppLog(response.body.toString());
      if (json.containsKey("MqttURL")) {
        return json["MqttURL"];
      }

      return "";
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    }
  }

  Future<MqttPermission?> getAclRules() async {
    if(token == null){
      await setupToken();
    }
    try {
      String uri = "${settingsController.baseUri.value}/prd/v2/acl-rules";
      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
      try {
        var response = await _client.get(Uri.parse(uri), headers: headers);
        print("ACL Response" + response.body.toString());
        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body.toString());
          if (jsonList.isNotEmpty) {
            return MqttPermission.fromJson(jsonList.first);
          }
          return null;
        }else{
          loggingService.showError("Error Downloading ACL Rules ${response.statusCode} ${response.body.toString()}");
        }
      } catch (e) {
        return null;
      }

      return null;
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    }    
  }

  Future<String?> getTimConfiguration() async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Downloading TIM Manifest");

      String uri = "${settingsController.baseUri.value}/prd/v2/tim/configuration";
      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
      try {
        var response = await _client.get(Uri.parse(uri), headers: headers);
        if (response.statusCode == 200) {
          return response.body.toString();
        }else{
          loggingService.showError("Error Downloading TIM Manifest: ${response.statusCode} ${response.body.toString()}");
        }
      } catch (e) {
        return null;
      }

      return null;
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    }    
  }

  Future<Uint8List?> getTimIcons(String version) async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Downloading TIM Icons");

      String uri = "${settingsController.baseUri.value}/prd/v2/tim/icons/$version";
      final Map<String, String> headers = {"Authorization": "Bearer $token", "Accept": "application/gzip"};

      try {
        var response = await _client.get(Uri.parse(uri), headers: headers);
        if (response.statusCode == 200) {
          return response.bodyBytes; 
        }else{
          loggingService.showError("Error Downloading TIM Icons: ${response.statusCode} ${response.body.toString()}");
        }
      } catch (e) {
        loggingService.showError("Error Downloading TIM Icons: $e");
        return null;
      }

      return null;
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to register app with API: $e");
      return null;
    }    
  }

  Future<PathResponse?> getPaths() async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Downloading Paths");
      final String uri = "${settingsController.baseUri.value}/prd/v2/paths";

      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      var response = await _client.get(Uri.parse(uri), headers: headers);
      if (response.statusCode == 200) {
      return PathResponse.fromJson(jsonDecode(response.body.toString()));
      }else{
        loggingService.showError("Error Code ${response.statusCode} ${response.body.toString()}");
        return null;
      }
      
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to retrieve paths from API: $e");
      return null;
    }
  }

  Future<SecretResponse?> getSecrets() async {
    if(token == null){
      await setupToken();
    }
    try {
      loggingService.addToAppLog("Downloading Secrets");
      final String uri = "${settingsController.baseUri.value}/prd/v2/secrets";

      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      var response = await _client.get(Uri.parse(uri), headers: headers);
      

      if (response.statusCode == 200) {
      return SecretResponse.fromJson(jsonDecode(response.body.toString()));
      }else{
        loggingService.showError("Error Code ${response.statusCode} ${response.body.toString()}");
        return null;
      }
    } on SocketException catch (e) {
      loggingService.showError("Caught exception when attempting to retrieve secrets from API: $e");
      return null;
    }
  }
}
