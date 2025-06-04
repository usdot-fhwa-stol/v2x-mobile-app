import 'dart:io';
import 'dart:convert';

import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/imp/registration.dart';
import 'package:cv_mec/pages/settings_page.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class ApiService extends GetxController {
  //final String baseURI = "http://cvmecapidns.eastus.azurecontainer.io:8080"; //SETTINGS Configuration
  SettingsController settingsController = Get.find<SettingsController>();

  Future getToken() async {
    try {
      print("generating token from api");

      String uri = "${settingsController.baseUri.value}/auth/token";
      final Map<String, String> headers = {"Content-Type": "application/json", "Accept": "application/json"};
      //SETTINGS Configuration
      final Map<String, String> body = {
        "username": settingsController.username.value, //"user", //TODO
        "password": settingsController.password.value, //"12345" //TODO
      };

      try {
        var response = await http.post(Uri.parse(uri), headers: headers, body: json.encode(body));
        if (response.statusCode == 200) {
          Map<String, dynamic> responseObject = jsonDecode(response.body.toString());
          if (responseObject.containsKey("access_token")) {
            return responseObject["access_token"];
          }
        }
      } catch (e) {
        return null;
      }

      return null;
    } on SocketException catch (e) {
      print("Caught exception when attempting to register app with API: $e");
      return null;
    }
  }

  Future getRegistration(String token, String clientType, String clientSubtype) async {
    try {
      print("Registring Device");
      // String imei = await DeviceImei().getDeviceImei() ?? "";
      final String uri = "${settingsController.baseUri.value}/prd/v2/registration";
      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      final String body = jsonEncode({
        "ClientType": clientType,
        "ClientSubtype": clientSubtype,
      });

      var response = await http.post(Uri.parse(uri), headers: headers, body: body);

      if (response.statusCode == 200) {
        dynamic registrationDyanmic = jsonDecode(response.body.toString());

        Registration registration = Registration.fromJson(registrationDyanmic);

        return registration;
      } else {
        print(response.body.toString());
      }
    } on SocketException catch (e) {
      print("Caught exception when attempting to register app with API: $e");
      return null;
    } catch (e) {
      print("Unable to Register app for unknown reasons");
      return null;
    }
  }

  Future getConnection(String token, String deviceID, double lat, double long, String networkType) async {
    try {
      print("Registring Device");
      // String imei = await DeviceImei().getDeviceImei() ?? "";
      final String uri = "${settingsController.baseUri.value}/prd/v2/connection";

      final Map<String, String> headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

      final String body = jsonEncode({"DeviceID": deviceID, "lat": lat, "long": long, "NetworkType": networkType});

      var response = await http.post(Uri.parse(uri), headers: headers, body: body);

      Map<String, dynamic> json = jsonDecode(response.body.toString());
      print(response.body.toString());
      if (json.containsKey("MqttURL")) {
        return json["MqttURL"];
      }

      return "";
    } on SocketException catch (e) {
      print("Caught exception when attempting to register app with API: $e");
      return null;
    }
  }
}
