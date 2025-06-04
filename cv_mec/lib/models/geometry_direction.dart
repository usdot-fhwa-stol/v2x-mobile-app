import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:dart_jts/dart_jts.dart';

class GeometryDirection {
  late Geometry geometry;
  HeadingSlice? direction;

  GeometryDirection(this.geometry, this.direction);
}
