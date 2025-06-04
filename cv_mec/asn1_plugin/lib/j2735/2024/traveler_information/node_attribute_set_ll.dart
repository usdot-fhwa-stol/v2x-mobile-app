import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/common/lane_data_attribute_list.dart';
import 'package:asn1_plugin/j2735/2024/common/offset_b10.dart';
import 'package:asn1_plugin/j2735/2024/common/regional_extension.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_attribute_ll_list.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/segment_attribute_ll_list.dart';

class NodeAttributeSetLL {
  NodeAttributeLLList? localNode;
  SegmentAttributeLLList? disabled;
  SegmentAttributeLLList? enabled;
  LaneDataAttributeList? data;
  Offset_B10? dWidth;
  Offset_B10? dElevation;
  RegionalExtension? regional;

  NodeAttributeSetLL.fromC(C.NodeAttributeSetLL nodeAttributeSetLL) {
    if (nodeAttributeSetLL.localNode.address != 0) {
      localNode = NodeAttributeLLList.fromC(nodeAttributeSetLL.localNode.ref);
    }

    if (nodeAttributeSetLL.disabled.address != 0) {
      disabled = SegmentAttributeLLList.fromC(nodeAttributeSetLL.disabled.ref);
    }

    if (nodeAttributeSetLL.enabled.address != 0) {
      enabled = SegmentAttributeLLList.fromC(nodeAttributeSetLL.enabled.ref);
    }

    if (nodeAttributeSetLL.data.address != 0) {
      data = LaneDataAttributeList.fromC(nodeAttributeSetLL.data.ref);
    }

    if (nodeAttributeSetLL.dWidth.address != 0) {
      dWidth = Offset_B10(nodeAttributeSetLL.dWidth.value);
    }

    if (nodeAttributeSetLL.dElevation.address != 0) {
      dElevation = Offset_B10(nodeAttributeSetLL.dElevation.value);
    }

    if (nodeAttributeSetLL.regional.address != 0) {
      // regional = RegionalExtension.fromC(nodeAttributeSetLL.regional.ref);
    }
  }
}
