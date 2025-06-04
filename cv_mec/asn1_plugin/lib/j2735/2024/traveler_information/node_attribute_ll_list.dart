import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_attribute_ll.dart';

class NodeAttributeLLList {
  late List<NodeAttributeLL> nodeAttributeLLList;

  NodeAttributeLLList.fromC(C.NodeAttributeLLList nodeAttributeLL) {
    nodeAttributeLLList = [];
    for (int i = 0; i < nodeAttributeLL.list.count; i++) {
      nodeAttributeLLList.add(NodeAttributeLL.values[nodeAttributeLL.list.array[i].value]);
    }
  }
}
