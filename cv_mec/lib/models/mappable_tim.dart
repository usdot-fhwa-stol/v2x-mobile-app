
import 'dart:math';

import 'package:asn1_plugin/j2735/2024/common/computed_lane.dart';
import 'package:asn1_plugin/j2735/2024/common/node_list_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/node_set_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/map_data/generic_lane.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/direction_of_use.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j3217/2022/toll_advertisement_message/toll_advertisement_message.dart';
import 'package:asn1_plugin/j3217/2022/toll_advertisement_message/toll_point_map.dart';
import 'package:cv_mec/models/geometry_direction.dart';
import 'package:cv_mec/models/itis/itis_sequence.dart';
import 'package:cv_mec/models/type_definitions.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:cv_mec/services/itis_decoding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

List<Color> timColors = [
  Colors.orange,
  const Color.fromARGB(255, 255, 168, 37),
  const Color.fromARGB(255, 244, 178, 79),
  const Color.fromARGB(255, 255, 196, 0),
  const Color.fromARGB(255, 255, 132, 0),
  const Color.fromARGB(255, 252, 191, 100),
];



class MappableTim {
  Polygon<HitValue> polygonPoints;
  List<Marker> timMarkers;


  MappableTim(
      {required this.polygonPoints,
      required this.timMarkers});

  static Future<MappableTim> fromTimGeometry(GeometryDirection geometryDirection, TravelerDataFrame frame) async {
    return MappableTim(
      polygonPoints: createPolygon(geometryDirection),
      timMarkers: await createTimMarkers(geometryDirection, frame),
    );
  }

  static Polygon<HitValue> createPolygon(GeometryDirection geometryDirection) {
    GeometryService geometryService = Get.find<GeometryService>();
    List<LatLng> polygonPoints = geometryService.convertGeometryToLatLngList(geometryDirection.geometry);
    List<LatLng> roundedPoints = geometryService.roundCorners(polygonPoints);
    int colorIndex = Random().nextInt(timColors.length);
    return Polygon(
      points: roundedPoints,
      borderColor: timColors[colorIndex],
      color: timColors[colorIndex].withValues(alpha: 0.5),
      borderStrokeWidth: 5,
    );
  }

  static Future<List<Marker>> createTimMarkers(GeometryDirection geometryDirection, TravelerDataFrame frame) async {
    GeometryService geometryService = Get.find<GeometryService>();
    ItisDecodingService itisDecodingService = Get.find<ItisDecodingService>();
    List<LatLng> polygonPoints = geometryService.convertGeometryToLatLngList(geometryDirection.geometry);
    List<LatLng> roundedPoints = geometryService.getCorners(polygonPoints);
    List<Marker> markers = [];
    ImageProvider itisImage = (await itisDecodingService.getSequenceForFrame(frame)).image;
    for (LatLng point in roundedPoints) {
      markers.add(Marker(
        width: 60.0,
        height: 60.0,
        point: point,
        child: Image(
          image: itisImage,
          fit: BoxFit.contain,
        ),
      ));
    }
    return markers;
  }
}