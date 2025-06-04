import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_attribute_set_ll.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_offset_point_ll.dart';

class NodeLL {
  late NodeOffsetPointLL delta;
  NodeAttributeSetLL? attributes;

  NodeLL.fromC(C.NodeLL nodeLL) {
    delta = NodeOffsetPointLL.fromC(nodeLL.delta);

    if (nodeLL.attributes.address != 0) {
      attributes = NodeAttributeSetLL.fromC(nodeLL.attributes.ref);
    }
  }
}
