import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/node_attribute_set_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/node_offset_point_xy.dart';

class NodeXY {
  late NodeOffsetPointXY delta;
  NodeAttributeSetXY? attributes;

  NodeXY.fromC(C.NodeXY nodeXY) {
    delta = NodeOffsetPointXY.fromC(nodeXY.delta);

    if (nodeXY.attributes.address != 0) {
      attributes = NodeAttributeSetXY.fromC(nodeXY.attributes.ref);
    }
  }
}
