import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_ll.dart';
import 'package:asn1_plugin/j2735/2024/common/node_llmd_64b.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll_24b.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll_28b.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll_32b.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll_36b.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll_44b.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_ll_48b.dart';

class NodeOffsetPointLL {
  late Choice_NodeOffsetPointLL nodeOffsetPointLL;

  NodeOffsetPointLL.fromC(C.NodeOffsetPointLL nodeOffsetPoint) {
    if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LL1) {
      nodeOffsetPointLL = Node_LL_24B.fromC(nodeOffsetPoint.choice.node_LL1);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LL2) {
      nodeOffsetPointLL = Node_LL_28B.fromC(nodeOffsetPoint.choice.node_LL2);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LL3) {
      nodeOffsetPointLL = Node_LL_32B.fromC(nodeOffsetPoint.choice.node_LL3);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LL4) {
      nodeOffsetPointLL = Node_LL_36B.fromC(nodeOffsetPoint.choice.node_LL4);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LL5) {
      nodeOffsetPointLL = Node_LL_44B.fromC(nodeOffsetPoint.choice.node_LL5);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LL6) {
      nodeOffsetPointLL = Node_LL_48B.fromC(nodeOffsetPoint.choice.node_LL6);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_node_LatLon) {
      nodeOffsetPointLL = Node_LLmD_64b.fromC(nodeOffsetPoint.choice.node_LatLon);
    } else if (nodeOffsetPoint.present == C.NodeOffsetPointLL_PR.NodeOffsetPointLL_PR_regional) {
    } else {
      print("Choice nodeOffsetPoint ${nodeOffsetPoint.present} is invalid for NodeOffsetPointLL");
    }
  }
}
