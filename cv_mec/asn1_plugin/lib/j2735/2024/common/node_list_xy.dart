import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_list_xy.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_offset.dart';
import 'package:asn1_plugin/j2735/2024/common/computed_lane.dart';
import 'package:asn1_plugin/j2735/2024/common/node_set_xy.dart';

class NodeListXY extends Choice_Offset {
  late Choice_NodeListXY nodeListXY;

  NodeListXY.fromC(C.NodeListXY c_nodeListXY) {
    if (c_nodeListXY.present == C.NodeListXY_PR.NodeListXY_PR_nodes) {
      nodeListXY = NodeSetXY.fromC(c_nodeListXY.choice.nodes);
    } else if (c_nodeListXY.present == C.NodeListXY_PR.NodeListXY_PR_computed) {
      nodeListXY = ComputedLane.fromC(c_nodeListXY.choice.computed);
    } else {
      print("Choice nodeListXY ${c_nodeListXY.present} is invalid for NodeListXY");
    }
  }
}
