import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/offset_b13.dart';

class Node_XY_26b extends Choice_NodeOffsetPointXY {
  late Offset_B13 x;
  late Offset_B13 y;

  Node_XY_26b.fromC(C.Node_XY_26b nodeXY26b) {
    x = Offset_B13(nodeXY26b.x);
    y = Offset_B13(nodeXY26b.y);
  }

  @override
  List<double> getOffsetMeters() {
    return [x.offset_B13 / 100.0, y.offset_B13 / 100.0];
  }
}
