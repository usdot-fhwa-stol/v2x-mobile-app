import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll.dart';

class NodeSetLL {
  late List<NodeLL> nodeSetLL;

  NodeSetLL.fromC(C.NodeSetLL nodeSet) {
    nodeSetLL = [];
    for (int i = 0; i < nodeSet.list.count; i++) {
      nodeSetLL.add(NodeLL.fromC(nodeSet.list.array[i].ref));
    }
  }
}
