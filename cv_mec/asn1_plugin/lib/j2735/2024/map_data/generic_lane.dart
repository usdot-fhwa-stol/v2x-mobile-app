import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/common/approach_id.dart';
import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/map_data/connects_to_list.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes.dart';
import 'package:asn1_plugin/j2735/2024/map_data/overlay_lane_list.dart';
import 'package:asn1_plugin/j2735/2024/common/lane_id.dart';
import 'package:asn1_plugin/j2735/2024/common/node_list_xy.dart';
import 'package:asn1_plugin/j2735/2024/map_data/allowed_maneuvers.dart';

class GenericLane {
  late LaneID laneID;
  DescriptiveName? name;
  ApproachID? ingressApproach;
  ApproachID? egressApproach;
  late LaneAttributes laneAttributes;

  AllowedManeuvers? maneuvers;
  late NodeListXY nodeList;
  ConnectsToList? connectsTo;
  OverlayLaneList? overlays;

  GenericLane.fromC(C.GenericLane c_genericLane) {
    laneID = LaneID(c_genericLane.laneID);

    if (c_genericLane.name.address != 0) {
      name = DescriptiveName.fromOctetString(c_genericLane.name.ref);
    }

    if (c_genericLane.ingressApproach.address != 0) {
      ingressApproach = ApproachID(c_genericLane.ingressApproach.value);
    }

    if (c_genericLane.egressApproach.address != 0) {
      egressApproach = ApproachID(c_genericLane.egressApproach.value);
    }

    laneAttributes = LaneAttributes.fromC(c_genericLane.laneAttributes);

    if (c_genericLane.maneuvers.address != 0) {
      maneuvers = AllowedManeuvers.fromBitString(c_genericLane.maneuvers.ref);
    }

    nodeList = NodeListXY.fromC(c_genericLane.nodeList);

    if (c_genericLane.connectsTo.address != 0) {
      connectsTo = ConnectsToList.fromC(c_genericLane.connectsTo.ref);
    }

    if (c_genericLane.overlays.address != 0) {
      overlays = OverlayLaneList.fromC(c_genericLane.overlays.ref);
    }
  }
}
