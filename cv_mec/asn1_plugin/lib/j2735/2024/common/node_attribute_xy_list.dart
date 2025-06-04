import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/common/node_attribute_xy.dart';

class NodeAttributeXYList {
  late List<NodeAttributeXY> nodeAttributeXYList;

  NodeAttributeXYList.fromC(C.NodeAttributeXYList nodeList) {
    nodeAttributeXYList = [];
    for (int i = 0; i < nodeList.list.count; i++) {
      nodeAttributeXYList.add(NodeAttributeXY.values[nodeList.list.array[i].value]);
    }
  }
}
