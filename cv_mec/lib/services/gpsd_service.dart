import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cv_mec/models/augmented_position.dart';
import 'package:cv_mec/models/gps_status.dart';
import 'package:cv_mec/models/gps_type.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:get/get.dart';

class GPSDService extends GetxService {
  LoggingService loggingService = Get.find<LoggingService>();
  final StreamController<AugmentedPosition> locationStream = StreamController<AugmentedPosition>.broadcast();

  Map<String, dynamic> parseHostAndPort(String input) {
    final parts = input.split(':');
    if (parts.length >= 2) {
      final host = parts[0];
      final port = int.tryParse(parts[1]);
      if (port != null) {
        return {'host': host, 'port': port};
      }else{
        loggingService.showError("Invalid port number in GPSD connection string: $input. Will use default port 2947 instead.");
        return {'host': host, 'port': 2947};
      }
    }else if(parts.length == 1){
      final host = parts[0];
      return {'host': host, 'port': 2947};
    } 
    return {'host': input, 'port': 2947};
  }

  void connectToGPSD(String host, int port) async {

    loggingService.addToAppLog("Connecting to GPSD at $host:$port");
    try {
      final socket = await Socket.connect(host, port);

      // Send GPSD WATCH command
      socket.write('?WATCH={"enable":true,"json":true};\n');

      // Listen for incoming GPS data
      socket.listen((data) {

        // HTTP Socket Data comes in as a stream, not as individual records. 
        // In the event that the data array contains more than 1 JSON object, only parse the last one.
        String textData = String.fromCharCodes(data);
        int startIndex = textData.lastIndexOf("{");
        int endIndex = textData.lastIndexOf("}");

        String lastRecord = textData.substring(startIndex, endIndex + 1);
        textData = textData.replaceAll("\r",'');
        try{
          Map<String,dynamic> jsonData = json.decode(lastRecord);

          if(jsonData.containsKey("lat")){ // Sometimes the GPS forwards a control packet that doesn't contain any other data
            locationStream.sink.add(AugmentedPosition(
            latitude: jsonData["lat"],
            longitude: jsonData["lon"],
            timestamp: DateTime.tryParse(jsonData["time"]) ?? DateTime.now(),
            accuracy: jsonData["eph"], // Estimated Position Error Horizontal
            altitude: jsonData["altHAE"], // Altitude Height Above Ellipsoid
            speed: jsonData["speed"], // Speed in m/s
            heading: jsonData["track"], 
            altitudeAccuracy: jsonData["epv"], // Estimated Position Error Vertical
            headingAccuracy: jsonData["epc"], // Estimated Course Error
            speedAccuracy: jsonData["eps"], // Estimated Speed Error
            gpsType: GPSType.obu,
            gpsStatus: GPSStatus.fromInt(jsonData["status"] ?? 0),
            ));
          }
            
        }catch (e) {
          loggingService.showError("Error parsing GPSD data: $e $textData");
        }
        
      });

    } catch (e) {
      loggingService.showError("Error parsing GPSD data: $e");
    }
  }
}
