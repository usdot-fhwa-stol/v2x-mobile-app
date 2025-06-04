import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/common/lane_width.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/common/road_segment_reference_id.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_limit_list.dart';
import 'package:asn1_plugin/j2735/2024/map_data/road_lane_set_list.dart';

class RoadSegment {
  DescriptiveName? name;
  late RoadSegmentReferenceID id;
  late MsgCount revision;
  late Position3D refPoint;
  LaneWidth? laneWidth;
  SpeedLimitList? speedLimits;
  late RoadLaneSetList roadLaneSet;

  RoadSegment.fromC(C.RoadSegment c_roadSegment) {
    if (c_roadSegment.name.address != 0) {
      name = DescriptiveName.fromOctetString(c_roadSegment.name.ref);
    }

    id = RoadSegmentReferenceID.fromC(c_roadSegment.id);

    revision = MsgCount(c_roadSegment.revision);

    refPoint = Position3D.fromC(c_roadSegment.refPoint);

    if (c_roadSegment.laneWidth != 0) {
      laneWidth = LaneWidth(c_roadSegment.laneWidth.value);
    }

    if (c_roadSegment.speedLimits.address != 0) {
      speedLimits = SpeedLimitList.fromC(c_roadSegment.speedLimits.ref);
    }

    roadLaneSet = RoadLaneSetList.fromC(c_roadSegment.roadLaneSet);
  }
}
