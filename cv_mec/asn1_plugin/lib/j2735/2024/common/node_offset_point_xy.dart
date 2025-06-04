import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/node_llmd_64b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy_20b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy_22b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy_24b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy_26b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy_28b.dart';
import 'package:asn1_plugin/j2735/2024/common/node_xy_32b.dart';

class NodeOffsetPointXY {
  late Choice_NodeOffsetPointXY nodeOffsetPointXY;

  NodeOffsetPointXY.fromC(C.NodeOffsetPointXY nodeOffset) {
    if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_XY1) {
      nodeOffsetPointXY = Node_XY_20b.fromC(nodeOffset.choice.node_XY1);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_XY2) {
      nodeOffsetPointXY = Node_XY_22b.fromC(nodeOffset.choice.node_XY2);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_XY3) {
      nodeOffsetPointXY = Node_XY_24b.fromC(nodeOffset.choice.node_XY3);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_XY4) {
      nodeOffsetPointXY = Node_XY_26b.fromC(nodeOffset.choice.node_XY4);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_XY5) {
      nodeOffsetPointXY = Node_XY_28b.fromC(nodeOffset.choice.node_XY5);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_XY6) {
      nodeOffsetPointXY = Node_XY_32b.fromC(nodeOffset.choice.node_XY6);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_node_LatLon) {
      nodeOffsetPointXY = Node_LLmD_64b.fromC(nodeOffset.choice.node_LatLon);
    } else if (nodeOffset.present == C.NodeOffsetPointXY_PR.NodeOffsetPointXY_PR_regional) {
      // nodeOffsetPointXY = RegionalExtension.fromC(nodeOffset.choice.regional);
    } else {
      print("Choice NodeOffsetPointXY ${nodeOffset.present} is invalid for NodeOffsetPointXY");
    }
  }
}
