import 'dart:math';

import 'package:asn1_plugin/j2735/2024/common/node_set_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/map_data/connection.dart';
import 'package:asn1_plugin/j2735/2024/map_data/generic_lane.dart';
import 'package:asn1_plugin/j2735/2024/map_data/intersection_geometry.dart';
import 'package:asn1_plugin/j2735/2024/map_data/map_data.dart';
import 'package:cv_mec/models/render_models/render_lane_connection.dart';
import 'package:cv_mec/models/render_models/render_light_location.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class GeoMap {
  late MapData map;
  late IntersectionGeometry intersectionGeometry;
  late Geometry mapBoundingBox;

  final int interpolationPoints = 20;

  Map<int, Geometry> laneBoundaries = {};
  Map<int, List<LatLng>> laneSegments = {};
  Map<int, Set<int>> laneSignalGroups = {};
  List<RenderLaneConnection> laneConnections = [];
  Map<LatLng, RenderLightLocation> lightLocations = {};

  final GeometryService _geometryService = Get.find<GeometryService>();

  GeoMap(MapData map, IntersectionGeometry intersectionGeometry) {
    this.map = map;
    this.intersectionGeometry = intersectionGeometry;
    laneBoundaries = {};

    if (intersectionGeometry.laneWidth != null) {
      for (GenericLane lane in intersectionGeometry.laneSet.laneList) {
        List<LatLng> laneCoordinates = _geometryService.getLatLngCoordinatesFromNodeSetXY(
            lane.nodeList.nodeListXY as NodeSetXY, intersectionGeometry.refPoint);

        Geometry? laneBoundingGeometry = _geometryService.getGeometryFromNodeListXY(
            lane.nodeList, intersectionGeometry.refPoint, intersectionGeometry.laneWidth!.getLaneWidthMeters());
        laneSegments[lane.laneID.laneID] = laneCoordinates;

        if (laneBoundingGeometry != null) {
          laneBoundaries[lane.laneID.laneID] = laneBoundingGeometry;
        }
      }
      mapBoundingBox = _geometryService.calculateMultiGeometryBoundingBox(laneBoundaries.values.toList());
    }
    calculateRenderLaneConnections();
  }

  void calculateRenderLaneConnections() {
    laneConnections = [];
    lightLocations = {};
    laneSignalGroups = {};

    for (GenericLane lane in intersectionGeometry.laneSet.laneList) {
      if (lane.connectsTo != null) {
        int ingressLaneId = lane.laneID.laneID;
        for (Connection connection in lane.connectsTo!.connectsTo) {
          int signalGroup = -1;
          if (connection.signalGroup != null) {
            signalGroup = connection.signalGroup!.signalGroupID;

            if (laneSignalGroups.containsKey(ingressLaneId)) {
              laneSignalGroups[ingressLaneId]!.add(signalGroup);
            } else {
              Set<int> s = <int>{};
              s.add(signalGroup);
              laneSignalGroups[ingressLaneId] = s;
            }
          }
          int connectId = connection.connectingLane.lane.laneID;
          List<LatLng> coordinates =
              calculateLaneConnectionCoordinates(ingressLaneId, connectId, intersectionGeometry.refPoint);

          laneConnections.add(RenderLaneConnection(coordinates, signalGroup));

          if (lightLocations.containsKey(coordinates.first)) {
            lightLocations[coordinates.first]!.signalGroups.add(signalGroup);
          } else {
            Set<int> signalGroups = {};
            signalGroups.add(signalGroup);
            lightLocations[coordinates.first] = RenderLightLocation(coordinates.first, signalGroups);
          }
        }
      }
    }
  }

  List<LatLng> calculateLaneConnectionCoordinates(int firstLaneId, int secondLaneId, Position3D refPoint) {
    if (laneSegments.containsKey(firstLaneId)) {
      if (laneSegments.containsKey(secondLaneId)) {
        LatLng startPoint = laneSegments[firstLaneId]!.first;
        LatLng leadInPoint = laneSegments[firstLaneId]![1];

        LatLng endPoint = laneSegments[secondLaneId]!.first;
        LatLng leadOutPoint = laneSegments[secondLaneId]![1];

        double angle = getAngle(leadInPoint, startPoint, endPoint, leadOutPoint);

        if (angle > 45) {
          LatLng? controlPoint = calculateLineIntersection(leadInPoint, startPoint, endPoint, leadOutPoint);

          if (controlPoint != null) {
            List<LatLng> points = calculateBezier(startPoint, endPoint, controlPoint);

            return points;
          }
        }

        LatLng firstPoint = laneSegments[firstLaneId]!.first;
        LatLng lastPoint = laneSegments[secondLaneId]!.first;
        return [firstPoint, lastPoint];
      }
    }

    return [];
  }

  double getAngle(LatLng p1, LatLng p2, LatLng p3, LatLng p4) {
    double dx1 = p2.longitude - p1.longitude;
    double dy1 = p2.latitude - p1.latitude;

    double dx2 = p4.longitude - p3.longitude;
    double dy2 = p4.latitude - p3.latitude;

    double theta = acos((dx1 * dx2 + dy1 * dy2) / (getLength(dx1, dy1) * getLength(dx2, dy2)));

    return radianToDeg(theta);
  }

  double getLength(double dx, double dy) {
    return sqrt(dx * dx + dy * dy);
  }

  LatLng? calculateLineIntersection(LatLng p1, LatLng p2, LatLng p3, LatLng p4) {
    double denominator = (p1.longitude - p2.longitude) * (p3.latitude - p4.latitude) -
        (p1.latitude - p2.latitude) * (p3.longitude - p4.longitude);

    if (denominator == 0) {
      return null;
    }

    double xNumerator = (p1.longitude * p2.latitude - p1.latitude * p2.longitude) * (p3.longitude - p4.longitude) -
        (p1.longitude - p2.longitude) * (p3.longitude * p4.latitude - p3.latitude * p4.longitude);
    double yNumerator = (p1.longitude * p2.latitude - p1.latitude * p2.longitude) * (p3.latitude - p4.latitude) -
        (p1.latitude - p2.latitude) * (p3.longitude * p4.latitude - p3.latitude * p4.longitude);

    return LatLng(yNumerator / denominator, xNumerator / denominator);
  }

  List<LatLng> calculateBezier(LatLng ingress, LatLng egress, LatLng control) {
    List<LatLng> bezier = [];

    for (double i = 0; i <= interpolationPoints; i++) {
      double t = (i / interpolationPoints);
      double latitude =
          pow((1 - t), 2) * ingress.latitude + 2 * (1 - t) * t * control.latitude + pow(t, 2) * egress.latitude;
      double longitude =
          pow((1 - t), 2) * ingress.longitude + 2 * (1 - t) * t * control.longitude + pow(t, 2) * egress.longitude;

      bezier.add(LatLng(latitude, longitude));
    }

    return bezier;
  }
}
