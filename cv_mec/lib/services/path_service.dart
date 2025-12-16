import 'dart:math';

import 'package:cv_mec/models/api_responses/path_response/path_response.dart';
import 'package:cv_mec/models/api_responses/path_response/vehicle_path.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class PathService{
  ApiService apiService = Get.find<ApiService>();
  GeometryService geometryService = Get.find<GeometryService>();

  PathResponse? pathResponse = null;

  Future<void> loadPaths() async {
    for(int i =0; i<3; i++){
      pathResponse = await apiService.getPaths();
      if(pathResponse != null) break;
      await Future.delayed(Duration(seconds: 3));
    }
  }

  List<String> getPathNames(){
    if(pathResponse != null){
      print("There are ${pathResponse!.paths.length} paths loaded.");
      return pathResponse!.paths.map((e) => e.name).toList();
    }
    return [];
  }

  VehiclePath? getPathByName(String name){
    if(pathResponse != null){
      try{
        return pathResponse!.paths.firstWhere((element) => element.name == name);
      }catch(e){
        return null;
      }
    }
    return null;
  }

  Stream<Position> followPath(VehiclePath vehiclePath) async* {
    List<List<double>> route = vehiclePath.geometry.coordinates;
    int count = 0;

    while (true) {
      int index = count % route.length;
      int prevIndex = (count - 1 + route.length) % route.length;

      List<double> pos = route[index];
      List<double> lastPos = route[prevIndex];

      double heading = radianToDeg(atan2(pos[1] - lastPos[1], pos[0] - lastPos[0]));

      num distance =
          geometryService.geodesy.distanceBetweenTwoGeoPoints(LatLng(pos[1], pos[0]), LatLng(lastPos[1], lastPos[0]));

      // Calculate delay based on timestamp difference
      int currentTimestamp = vehiclePath.timestamps[index];
      int prevTimestamp = vehiclePath.timestamps[prevIndex];
      

      int timestampDiff = (currentTimestamp - prevTimestamp);
      print("Delay${route.length} - $index - $prevIndex : $currentTimestamp - $prevTimestamp = $timestampDiff");
      if (timestampDiff <=0) {
        // If looping back to start, estimate delay based on average speed
        timestampDiff = 100; // Default to 100 ms for loopback
      }

      // Use timestamp difference for delay, with a minimum of 10ms
      Duration delay = Duration(milliseconds: max(10, timestampDiff));
      
      
      double speed = distance / (delay.inMilliseconds / 1000.0);

      heading = -heading + 90;
      if (heading < 0) {
        heading += 360;
      }

      yield Position(
          longitude: route[index][0],
          latitude: route[index][1],
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 1600,
          altitudeAccuracy: 0,
          heading: heading,
          headingAccuracy: 0,
          speed: speed,
          speedAccuracy: 0);
      await Future.delayed(delay);
      count++;
    }
  }
}