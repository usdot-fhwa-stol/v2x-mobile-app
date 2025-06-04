import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/choice/choice_description.dart';
import 'package:asn1_plugin/j2735/2024/common/extent.dart';
import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:asn1_plugin/j2735/2024/common/lane_width.dart';
import 'package:asn1_plugin/j2735/2024/common/regional_extension.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/circle.dart';

class GeometricProjection extends Choice_Description {
  late HeadingSlice direction;
  Extent? extent;
  LaneWidth? laneWidth;
  late Circle circle;

  List<RegionalExtension>? regional;

  GeometricProjection.fromC(C.GeometricProjection geometricProjection) {
    direction = HeadingSlice.fromBitString(geometricProjection.direction);

    if (geometricProjection.extent.address != 0) {
      extent = Extent.values[geometricProjection.extent.value];
    }

    if (geometricProjection.laneWidth.address != 0) {
      laneWidth = LaneWidth(geometricProjection.laneWidth.value);
    }

    circle = Circle.fromC(geometricProjection.circle);
  }
}
