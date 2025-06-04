import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/common/intersection_reference_id.dart';
import 'package:asn1_plugin/j2735/2024/common/lane_width.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_limit_list.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_list.dart';
import 'package:asn1_plugin/j2735/2024/map_data/preempt_priority_list.dart';

class IntersectionGeometry {
  DescriptiveName? name;
  late IntersectionReferenceID id;
  late MsgCount revision;
  late Position3D refPoint;
  LaneWidth? laneWidth;
  SpeedLimitList? speedLimits;
  late LaneList laneSet;
  PreemptPriorityList? preemptPriorityData;

  IntersectionGeometry.fromC(C.IntersectionGeometry c_intersectionGeometry) {
    if (c_intersectionGeometry.name.address != 0) {
      name = DescriptiveName.fromOctetString(c_intersectionGeometry.name.ref);
    }

    id = IntersectionReferenceID.fromC(c_intersectionGeometry.id);

    revision = MsgCount(c_intersectionGeometry.revision);

    refPoint = Position3D.fromC(c_intersectionGeometry.refPoint);

    if (c_intersectionGeometry.laneWidth.address != 0) {
      laneWidth = LaneWidth(c_intersectionGeometry.laneWidth.value);
    }

    if (c_intersectionGeometry.speedLimits.address != 0) {
      speedLimits = SpeedLimitList.fromC(c_intersectionGeometry.speedLimits.ref);
    }

    laneSet = LaneList.fromC(c_intersectionGeometry.laneSet);

    if (c_intersectionGeometry.preemptPriorityData.address != 0) {
      preemptPriorityData = PreemptPriorityList.fromC(c_intersectionGeometry.preemptPriorityData.ref);
    }
  }
}
