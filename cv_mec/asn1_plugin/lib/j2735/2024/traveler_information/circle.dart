import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/distance_units.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/radius_b12.dart';

class Circle {
  late Position3D center;
  late Radius_B12 radius;
  late DistanceUnits units;

  Circle.fromC(C.Circle circle) {
    center = Position3D.fromC(circle.center);
    radius = Radius_B12(circle.radius);
    units = DistanceUnits.values[circle.units];
  }
}
