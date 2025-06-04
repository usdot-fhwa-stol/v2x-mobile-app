import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_offset.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_set_ll.dart';

class NodeListLL extends Choice_Offset {
  late NodeSetLL nodes;

  NodeListLL.fromC(C.NodeListLL nodeListLL) {
    if (nodeListLL.present == C.NodeListLL_PR.NodeListLL_PR_nodes) {
      nodes = NodeSetLL.fromC(nodeListLL.choice.nodes);
    } else {
      print("Choice nodes ${nodeListLL.present} is invalid for NodeListLL");
    }
  }
}
