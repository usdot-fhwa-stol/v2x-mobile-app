import 'package:asn1_plugin/j2735/2024/common/computed_lane.dart';
import 'package:asn1_plugin/j2735/2024/common/node_list_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/node_set_xy.dart';
import 'package:asn1_plugin/j2735/2024/map_data/generic_lane.dart';
import 'package:asn1_plugin/j3217/2022/toll_advertisement_message/toll_advertisement_message.dart';
import 'package:asn1_plugin/j3217/2022/toll_advertisement_message/toll_point_map.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';


class MappableTam {
  final TollAdvertisementMessage? tam;
  List<List<LatLng>> polylinePoints = [];


  MappableTam(
      {required this.tam,
      required this.polylinePoints,
      });

  // Custom constructor using an initializer list
  MappableTam.fromTam(this.tam) {
    _initializePolylinePoints(tam!);
  }

  // Test constructor with sample data
  MappableTam.sample()
      : tam = null,
        polylinePoints = [
          [
            LatLng(40.473601, -104.970177),
            LatLng(40.475474, -104.967162),
          ],
        ];

  void _initializePolylinePoints(TollAdvertisementMessage tam) {
    GeometryService geometryService = Get.find<GeometryService>();
    if (tam.tollAdvInfo != null) {
      TollPointMap tollPointMap = tam.tollAdvInfo!.tollPointMap;
      TollZoneLanesMap tollZoneLanesMap = tollPointMap.tollZoneLanesMap;
      for (GenericLane lane in tollZoneLanesMap.tollZoneLanesMap) {
        List<LatLng> lanePoints = [];
        NodeListXY nodeList = lane.nodeList;
        if (nodeList is NodeSetXY) {
          NodeSetXY nodeSet = nodeList as NodeSetXY;
          lanePoints = geometryService.getLatLngCoordinatesFromNodeSetXY(nodeSet, tollPointMap.referencePoint);
          polylinePoints.add(lanePoints);
        }
      }
    }
    _addSampleTamPolylinePoints();
    print("Cookie Initialized TAM with ${polylinePoints.length} polylines.");
  }

  void _addSampleTamPolylinePoints() {
    // Add sample polyline points for demonstration
    polylinePoints.add([
      LatLng(40.473601, -104.970177),
      LatLng(40.475474, -104.967162),
    ]);
  }
}
