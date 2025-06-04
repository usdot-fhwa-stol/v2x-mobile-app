import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/lane_data_attribute_list.dart';
import 'package:asn1_plugin/j2735/2024/common/node_attribute_xy_list.dart';
import 'package:asn1_plugin/j2735/2024/common/offset_b10.dart';
import 'package:asn1_plugin/j2735/2024/common/regional_extension.dart';
import 'package:asn1_plugin/j2735/2024/common/segment_attribute_xy_list.dart';

class NodeAttributeSetXY {
  NodeAttributeXYList? localNode;
  SegmentAttributeXYList? disabled;
  SegmentAttributeXYList? enabled;
  LaneDataAttributeList? data;
  Offset_B10? dWidth;
  Offset_B10? dElevation;
  List<RegionalExtension>? regional;

  NodeAttributeSetXY.fromC(C.NodeAttributeSetXY nodeAttributeSetXY) {
    if (nodeAttributeSetXY.localNode.address != 0) {
      localNode = NodeAttributeXYList.fromC(nodeAttributeSetXY.localNode.ref);
    }

    if (nodeAttributeSetXY.disabled.address != 0) {
      disabled = SegmentAttributeXYList.fromC(nodeAttributeSetXY.disabled.ref);
    }

    if (nodeAttributeSetXY.enabled.address != 0) {
      enabled = SegmentAttributeXYList.fromC(nodeAttributeSetXY.enabled.ref);
    }

    if (nodeAttributeSetXY.data.address != 0) {
      data = LaneDataAttributeList.fromC(nodeAttributeSetXY.data.ref);
    }

    if (nodeAttributeSetXY.dWidth.address != 0) {
      dWidth = Offset_B10(nodeAttributeSetXY.dWidth.value);
    }

    if (nodeAttributeSetXY.dElevation.address != 0) {
      dWidth = Offset_B10(nodeAttributeSetXY.dElevation.value);
    }
  }
}
