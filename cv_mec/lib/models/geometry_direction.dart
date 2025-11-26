
import 'dart:math';

import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/direction_of_use.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:latlong2/latlong.dart';

class GeometryDirection {
  late Geometry geometry;
  HeadingSlice? direction;
  List<LatLng>? coordinates;
  DirectionOfUse? directionOfUse;


  GeometryDirection(this.geometry, this.direction, this.coordinates, this.directionOfUse);
  final double alignmentThreshold = 45;


  bool isInPathDirection(double longitude, double latitude, double heading){
    if(directionOfUse != null && coordinates != null){
      switch(directionOfUse!){
        case DirectionOfUse.unavailable:
          return false;
        case DirectionOfUse.both:
          return true;
        case DirectionOfUse.forward:
          double angleOffset = getPointPathOffsetAngle(longitude, latitude, heading);
          return angleOffset > -alignmentThreshold && angleOffset < alignmentThreshold;
        case DirectionOfUse.reverse:
          double angleOffset = getPointPathOffsetAngle(longitude, latitude, heading);
          return angleOffset > (180 - alignmentThreshold) || angleOffset < (-180 + alignmentThreshold);
      }
    }
    return false;
  }

  // This function checks if the provided direction at the given point is in the same direction as the path.
  // This calculation is done by finding the closest point on the path to the provided point and checking if the angle between the path segment and the provided heading is less than 90 degrees.
  double getPointPathOffsetAngle(double longitude, double latitude, double headingDegrees) {
    double direction = 0;
    double closestDistance = double.infinity;

    double headingRadians = degToRadian(headingDegrees);
    double deltaNorth = cos(headingRadians);
    double deltaEast = sin(headingRadians);


    for(int i =1; i< coordinates!.length; i++){
      LatLng position = coordinates![i];
      // Perform a fast relative distance check. 
      double distanceSquared = (pow(position.latitude - latitude, 2) + pow(position.longitude - longitude, 2)).toDouble();
      if (distanceSquared < closestDistance) {
        closestDistance = distanceSquared;

        double pathDeltaNorth = position.latitude - coordinates![i-1].latitude;
        double pathDeltaEast = position.longitude - coordinates![i-1].longitude;
        double magnitude = sqrt(pow(pathDeltaNorth, 2) + pow(pathDeltaEast, 2));
        direction = deltaNorth * (pathDeltaNorth/magnitude) + deltaEast * (pathDeltaEast/magnitude);
        
      }
    }

    // Direction should be set to the dot product of the heading vector and the path segment vector.
    // Values greater than 0 indicate the same direction, values less than 0 indicate the opposite direction.
    // values equal to 0 indicate that the point is perpendicular to the path segment.
    return radianToDeg(acos(direction));
  }
}
