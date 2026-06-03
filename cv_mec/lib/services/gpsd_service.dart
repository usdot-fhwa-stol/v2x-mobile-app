import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cv_mec/services/logging_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class GPSDService extends GetxService {
  LoggingService loggingService = Get.find<LoggingService>();
  final StreamController<Position> locationStream = StreamController<Position>.broadcast();

  void connectToGPSD(String host, int port) async {
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
            locationStream.sink.add(Position(
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
