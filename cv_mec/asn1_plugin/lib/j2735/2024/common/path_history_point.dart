import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/coarse_heading.dart';
import 'package:asn1_plugin/j2735/2024/common/positional_accuracy.dart';
import 'package:asn1_plugin/j2735/2024/common/speed.dart';
import 'package:asn1_plugin/j2735/2024/common/time_offset.dart';
import 'package:asn1_plugin/j2735/2024/common/vert_offset_b12.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/offset_ll_b18.dart';

class PathHistoryPoint {
  late OffsetLL_B18 latOffset;
  late OffsetLL_B18 lonOffset;

  late VertOffset_B12 elevationOffset;
  late TimeOffset timeOffset;
  Speed? speed;
  PositionalAccuracy? posAccuracy;
  CoarseHeading? heading;

  PathHistoryPoint.fromC(C.PathHistoryPoint c_pathHistoryPoint) {
    latOffset = OffsetLL_B18(c_pathHistoryPoint.latOffset);
    lonOffset = OffsetLL_B18(c_pathHistoryPoint.lonOffset);

    elevationOffset = VertOffset_B12(c_pathHistoryPoint.elevationOffset);

    timeOffset = TimeOffset(c_pathHistoryPoint.timeOffset);

    if (c_pathHistoryPoint.speed.address != 0) {
      speed = Speed(c_pathHistoryPoint.speed.value);
    }

    if (c_pathHistoryPoint.posAccuracy.address != 0) {
      posAccuracy = PositionalAccuracy.fromC(c_pathHistoryPoint.posAccuracy.ref);
    }

    if (c_pathHistoryPoint.heading.address != 0) {
      heading = CoarseHeading(c_pathHistoryPoint.heading.value);
    }
  }
}
