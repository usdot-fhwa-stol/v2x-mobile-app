import 'dart:math';

import 'package:asn1_plugin/j2735/2024/common/computed_lane.dart';
import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:asn1_plugin/j2735/2024/common/node_list_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/node_llmd_64b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_set_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/distance_units.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/geographical_path.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/geometric_projection.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_list_ll.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/offset_system.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:cv_mec/models/geometry_direction.dart';
import 'package:cv_mec/models/data_frame_geometry.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geodesy/geodesy.dart' as geo;

class GeometryService {
  GeometryFactory geometryFactory = GeometryFactory.defaultPrecision();
  final geodesy = geo.Geodesy();

  Map<TravelerDataFrame, DataFrameGeometry> getTimPolyRegion(TravelerInformation tim) {
    Map<TravelerDataFrame, DataFrameGeometry> dataFrameRegions = <TravelerDataFrame, DataFrameGeometry>{};
    for (int i = 0; i < tim.dataFrames.travelerDataFrameList.length; i++) {
      TravelerDataFrame travelerDataFrame = tim.dataFrames.travelerDataFrameList[i];
      List<GeometryDirection> timGeometryList = [];
      for (int j = 0; j < travelerDataFrame.regions.length; j++) {
        Geometry? timGeometry = getGeometryFromPath(travelerDataFrame.regions[j]);

        HeadingSlice? direction = travelerDataFrame.regions[j].direction;

        if (travelerDataFrame.regions[j].description is GeometricProjection) {
          direction = (travelerDataFrame.regions[j].description as GeometricProjection).direction;
        }

        if (timGeometry != null) {
          GeometryDirection geoDir = GeometryDirection(timGeometry, direction);

          timGeometryList.add(geoDir);
        }
      }
      dataFrameRegions[travelerDataFrame] = DataFrameGeometry(travelerDataFrame, timGeometryList);
    }

    return dataFrameRegions;
  }

  Geometry? getGeometryFromPath(GeographicalPath path) {
    if (path.description is OffsetSystem) {
      return getGeometryFromOffsetSystem(
          path.description as OffsetSystem, path.anchor!, path.laneWidth!.getLaneWidthMeters());
    } else if (path.description is GeometricProjection) {
      return getGeometryFromGeometricProjection(path.description as GeometricProjection);
    } else {
      print("Unable to Parse Path. Path is not OffsetSystem or Geometric Projection");
      return null;
    }
  }

  Geometry? getGeometryFromOffsetSystem(OffsetSystem offsetSystem, Position3D anchor, double laneWidth) {
    if (offsetSystem.offset is NodeListXY) {
      return getGeometryFromNodeListXY(offsetSystem.offset as NodeListXY, anchor, laneWidth);
    } else if (offsetSystem.offset is NodeListLL) {
      return getGeometryFromNodeListLL(offsetSystem.offset as NodeListLL, anchor, laneWidth);
    } else {
      print("Unable to Identify the Type of OffsetSystem");
    }
    return null;
  }

  Geometry? getGeometryFromNodeListXY(NodeListXY nodeListXY, Position3D anchor, double laneWidth) {
    if (nodeListXY.nodeListXY is NodeSetXY) {
      return getGeometryFromNodeSetXY(nodeListXY.nodeListXY as NodeSetXY, anchor, laneWidth);
    } else if (nodeListXY.nodeListXY is ComputedLane) {
      print("Unable to Parse Computed NodeListXY System. Not Supported");
      return null;
    } else {
      print("Unable to Identify the Type of NodeListXY");
    }
    return null;
  }

  Geometry? getGeometryFromNodeListLL(NodeListLL nodeListLL, Position3D anchor, double laneWidth) {
    List<Coordinate> polygon = getPolygonFromPointPath(getCoordinatesNodeListLL(nodeListLL, anchor), laneWidth);

    if (polygon.length >= 3) {
      Geometry timGeometry = convertCoordinatesToGeoPoly(polygon, anchor);
      return timGeometry;
    } else {
      print("Unable to Add Geometry. Anchor Point: $anchor, Coordinate Length: ${polygon.length}");
    }

    return null;
  }

  // Returns a list of Coordinates as offset Meters from the anchor point
  Geometry? getGeometryFromNodeSetXY(NodeSetXY nodeSetXY, Position3D anchor, double laneWidth) {
    List<Coordinate> polygon = getPolygonFromPointPath(getCoordinatesFromNodeSetXY(nodeSetXY, anchor), laneWidth);

    if (polygon.length >= 3) {
      Geometry timGeometry = convertCoordinatesToGeoPoly(polygon, anchor);
      return timGeometry;
    } else {
      print("Unable to Add Geometry. Anchor Point: $anchor, Coordinate Length: ${polygon.length}");
      return null;
    }
  }

  getGeometryFromGeometricProjection(GeometricProjection projection) {
    // LatLng centerLatLng = position3DtoLatLng(projection.circle.center);
    // Coordinate centerCoordinate = Coordinate.fromYX(0, 0);

    List<Coordinate> boundary = [];

    int resolution = 100;
    double thetaIncrement = 2 * pi / resolution;
    int radiusUnits = projection.circle.radius.radius;

    DistanceUnits units = projection.circle.units;

    double radius = convertDistanceToMeters(radiusUnits.toDouble(), units);

    for (int i = 0; i < resolution; i++) {
      double theta = i * thetaIncrement;
      boundary.add(Coordinate(radius * cos(theta), radius * sin(theta)));
    }

    return convertCoordinatesToGeoPoly(boundary, projection.circle.center);
  }

  List<Coordinate> getPolygonFromPointPath(List<Coordinate> points, double laneWidth) {
    LineString lineString = geometryFactory.createLineString(points);

    BufferParameters bufferParams = BufferParameters();
    bufferParams.setEndCapStyle(BufferParameters.CAP_FLAT);
    bufferParams.setJoinStyle(BufferParameters.JOIN_BEVEL);
    bufferParams.setSimplifyFactor(0.001);

    Geometry buffer = BufferOp.bufferOpWithParams(lineString, laneWidth / 2.0, bufferParams);

    List<Coordinate> coordinates = buffer.getCoordinates();
    return coordinates;
  }

  Coordinate latLngToCoordinate(LatLng latLng, Position3D anchorPoint) {
    LatLng anchor = LatLng(anchorPoint.lat.getDecimalLatitude(), anchorPoint.long.getDecimalLongitude());

    num bearing = geodesy.bearingBetweenTwoGeoPoints(anchor, latLng);
    num distance = geodesy.distanceBetweenTwoGeoPoints(anchor, latLng);

    double theta = bearing * pi / 180;
    double x = distance * cos(theta);
    double y = distance * sin(theta);

    return Coordinate(x, y);
  }

  LatLng coordinateToLatLng(Coordinate coordinate, Position3D anchorPoint) {
    LatLng anchor = LatLng(anchorPoint.lat.getDecimalLatitude(), anchorPoint.long.getDecimalLongitude());
    return shiftLatLng(anchor, coordinate.y, coordinate.x);
  }

  LatLng shiftLatLng(LatLng point, double metersNorth, double metersEast) {
    double degrees = atan2(metersNorth, metersEast) * 180.0 / pi;
    double distance = sqrt(pow(metersNorth, 2) + pow(metersEast, 2));
    LatLng destinationPoints = geodesy.destinationPointByDistanceAndBearing(point, distance, degrees);
    return destinationPoints;
  }

  LatLng position3DtoLatLng(Position3D pos) {
    return LatLng(pos.lat.getDecimalLatitude(), pos.long.getDecimalLongitude());
  }

  Geometry convertCoordinatesToGeoPoly(List<Coordinate> coordinates, Position3D anchorPoint) {
    Polygon polygon = geometryFactory
        .createPolygonFromCoords(normalizeCoordinatesToPolygon(convertCoordinatesToLatLng(coordinates, anchorPoint)));
    return polygon;
  }

  List<Coordinate> convertCoordinatesToLatLng(List<Coordinate> coordinates, Position3D anchorPoint) {
    List<Coordinate> latLngCoordinates = [];
    for (int i = 0; i < coordinates.length; i++) {
      final converted = coordinateToLatLng(coordinates[i], anchorPoint);
      latLngCoordinates.add(Coordinate(converted.longitude, converted.latitude));
    }
    return latLngCoordinates;
  }

  void printGeoPoly(Geometry geometry) {
    printLongString(geometry.toText());
  }

  void printLongString(String text) {
    const int chunkSize = 800; // Define the chunk size
    for (int i = 0; i < text.length; i += chunkSize) {
      print(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }

  List<Coordinate> normalizeCoordinatesToPolygon(List<Coordinate> coordinates) {
    if (coordinates.length < 3) {
      return coordinates;
    } else {
      while (coordinates[0].equals(coordinates[1])) {
        coordinates.removeAt(0);
      }

      if (!coordinates.last.equals(coordinates.first)) {
        coordinates.add(Coordinate(coordinates.first.x, coordinates.first.y));
      }
    }
    return coordinates;
  }

  List<LatLng> convertGeometryToLatLngList(Geometry geometry) {
    return switchCoordinateListToLatLngList(geometry.getCoordinates());
  }

  List<LatLng> switchCoordinateListToLatLngList(List<Coordinate> coords) {
    List<LatLng> latLngs = [];
    for (Coordinate coord in coords) {
      latLngs.add(LatLng(coord.y, coord.x));
    }
    return latLngs;
  }

  bool isPointInPolygon(Geometry geometry, double x, double y) {
    Coordinate coordinate = Coordinate(x, y);
    Point point = geometryFactory.createPoint(coordinate);
    return geometry.contains(point);
  }

  bool isPointInPolygonWithMargin(Geometry geometry, double x, double y, double margin) {
    Coordinate coordinate = Coordinate(x, y);
    Point point = geometryFactory.createPoint(coordinate);

    Geometry bufferedGeometry = geometry.buffer(margin);

    return bufferedGeometry.contains(point);
  }

  Geometry calculateMultiGeometryBoundingBox(List<Geometry> geometries) {
    Envelope? combinedEnvelope;
    for (Geometry geo in geometries) {
      if (combinedEnvelope == null) {
        combinedEnvelope = geo.computeEnvelopeInternal();
      } else {
        combinedEnvelope.expandToIncludeEnvelope(geo.computeEnvelopeInternal());
      }
    }

    if (combinedEnvelope != null) {
      List<Coordinate> coordinates = [
        Coordinate(combinedEnvelope.getMinX(), combinedEnvelope.getMinY()),
        Coordinate(combinedEnvelope.getMaxX(), combinedEnvelope.getMinY()),
        Coordinate(combinedEnvelope.getMaxX(), combinedEnvelope.getMaxY()),
        Coordinate(combinedEnvelope.getMinX(), combinedEnvelope.getMaxY())
      ];
      return geometryFactory.createPolygonFromCoords(normalizeCoordinatesToPolygon(coordinates));
    }

    return geometryFactory.createPolygonEmpty();
  }

  double convertDistanceToMeters(double distance, DistanceUnits originalUnits) {
    if (originalUnits == DistanceUnits.centimeter) {
      return distance / 100.0;
    } else if (originalUnits == DistanceUnits.cm2_5) {
      //Steps of 2.5 Cm
      return distance * 2.5 / 100.0;
    } else if (originalUnits == DistanceUnits.decimeter) {
      return distance / 10.0;
    } else if (originalUnits == DistanceUnits.meter) {
      return distance;
    } else if (originalUnits == DistanceUnits.kilometer) {
      return distance * 1000.0;
    } else if (originalUnits == DistanceUnits.foot) {
      return 0.3048 * distance;
    } else if (originalUnits == DistanceUnits.yard) {
      return 3 * 0.3048 * distance;
    } else if (originalUnits == DistanceUnits.mile) {
      return 5280 * 0.3048 * distance;
    } else {
      return distance;
    }
  }

  List<Coordinate> getCoordinatesFromNodeListXY(NodeListXY nodeListXY, Position3D anchor) {
    return getCoordinatesFromNodeSetXY(nodeListXY.nodeListXY as NodeSetXY, anchor);
  }

  List<LatLng> getLatLngCoordinatesFromNodeSetXY(NodeSetXY nodeSetXY, Position3D anchor) {
    List<Coordinate> coords = getCoordinatesFromNodeSetXY(nodeSetXY, anchor);

    return switchCoordinateListToLatLngList(convertCoordinatesToLatLng(coords, anchor));
  }

  List<Coordinate> getCoordinatesFromNodeSetXY(NodeSetXY nodeSetXY, Position3D anchor) {
    List<Coordinate> points = [];
    LatLng anchorLatLng = LatLng(anchor.lat.getDecimalLatitude(), anchor.long.getDecimalLongitude());
    for (int i = 0; i < nodeSetXY.nodeSetXY.length; i++) {
      NodeXY node = nodeSetXY.nodeSetXY[i];

      // Handle the case where we get the
      if (node.delta.nodeOffsetPointXY is Node_LLmD_64b) {
        Node_LLmD_64b refLatLong = node.delta.nodeOffsetPointXY as Node_LLmD_64b;

        final refLatLng = LatLng(refLatLong.lat.getDecimalLatitude(), refLatLong.lon.getDecimalLongitude());

        num bearing = geodesy.bearingBetweenTwoGeoPoints(anchorLatLng, refLatLng);
        num distance = geodesy.distanceBetweenTwoGeoPoints(anchorLatLng, refLatLng);

        double theta = bearing * pi / 180;

        double x = distance * cos(theta);
        double y = distance * sin(theta);

        points.add(Coordinate(x, y));
      } else {
        List<double> offset = node.delta.nodeOffsetPointXY.getOffsetMeters();

        if (points.isEmpty) {
          points.add(Coordinate(offset[1], offset[0]));
        } else {
          points.add(Coordinate(points.last.x + offset[1], points.last.y + offset[0]));
        }
      }
    }

    return points;
  }

  List<Coordinate> getCoordinatesNodeListLL(NodeListLL nodeListLL, Position3D anchor) {
    List<LatLng> latLngs = [];

    LatLng anchorLatLng = LatLng(anchor.lat.getDecimalLatitude(), anchor.long.getDecimalLongitude());

    for (NodeLL node in nodeListLL.nodes.nodeSetLL) {
      if (node.delta.nodeOffsetPointLL is Node_LLmD_64b) {
        Node_LLmD_64b refLatLong = node.delta.nodeOffsetPointLL as Node_LLmD_64b;

        final refLatLng = LatLng(refLatLong.lat.getDecimalLatitude(), refLatLong.lon.getDecimalLongitude());
        latLngs.add(refLatLng);
      } else {
        List<double> offset = node.delta.nodeOffsetPointLL.getOffsetLongLat();

        if (latLngs.isEmpty) {
          latLngs.add(LatLng(offset[1] + anchorLatLng.latitude, offset[0] + anchorLatLng.longitude));
        } else {
          latLngs.add(LatLng(latLngs.last.latitude + offset[1], latLngs.last.longitude + offset[0]));
          // points.add(Coordinate(points.last.x + offset[0], points.last.y + offset[1]));
        }
      }
    }

    // Convert Lat Long list back to meters. Required for lane expansion later
    List<Coordinate> points = [];
    for (LatLng pos in latLngs) {
      points.add(latLngToCoordinate(pos, anchor));
    }

    return points;
  }

  List<LatLng> getPolygonProjection(LatLng position, double degrees, double laneWidth) {
    double radians = degToRadian(-(degrees - 90));
    double distance = 100;

    Coordinate start = Coordinate(0, 0);
    Coordinate end = Coordinate(distance * sin(radians), distance * cos(radians));

    List<Coordinate> coordinates = [start, end];

    List<Coordinate> polygon = getPolygonFromPointPath(coordinates, laneWidth);

    List<LatLng> latLngCoordinates = [];
    for (int i = 0; i < polygon.length; i++) {
      LatLng anchor = LatLng(position.latitude, position.longitude);
      final converted = shiftLatLng(anchor, polygon[i].y, polygon[i].x);
      latLngCoordinates.add(LatLng(converted.latitude, converted.longitude));
    }
    return latLngCoordinates;
  }

  Polygon getConicSectionProjection(LatLng position, double degrees, double startingWidth, double fov, double length) {
    List<Coordinate> coordinates = [];

    double radians = degToRadian(-(degrees - 90));
    double normal = degToRadian(-(degrees - 90) + 90);
    double fovRadians = degToRadian(fov) / 2.0;

    double startingOffset = startingWidth / 2;

    double h = length / (cos(fovRadians));

    Coordinate positiveOffsetCoordinate = Coordinate(startingOffset * cos(normal), startingOffset * sin(normal));
    Coordinate negativeOffsetCoordinate = Coordinate(-startingOffset * cos(normal), -startingOffset * sin(normal));
    Coordinate positiveCorner =
        positiveOffsetCoordinate + Coordinate(h * cos(radians + fovRadians), h * sin(radians + fovRadians));
    Coordinate negativeCorner =
        negativeOffsetCoordinate + Coordinate(h * cos(radians - fovRadians), h * sin(radians - fovRadians));

    // coordinates.add(Coordinate(0, 0));
    coordinates.add(positiveOffsetCoordinate);
    coordinates.add(positiveCorner);
    coordinates.add(negativeCorner);
    coordinates.add(negativeOffsetCoordinate);
    coordinates.add(positiveOffsetCoordinate);

    List<Coordinate> latLngCoordinates = [];
    // print("Coordinate:");
    for (int i = 0; i < coordinates.length; i++) {
      final converted = shiftLatLng(position, coordinates[i].x, coordinates[i].y);
      latLngCoordinates.add(Coordinate(converted.longitude, converted.latitude));
    }

    return geometryFactory.createPolygonFromCoords(latLngCoordinates);

    // return latLngCoordinates;
  }
}
