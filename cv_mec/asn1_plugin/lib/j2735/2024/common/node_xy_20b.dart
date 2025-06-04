import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/offset_b10.dart';

class Node_XY_20b extends Choice_NodeOffsetPointXY {
  late Offset_B10 x;
  late Offset_B10 y;

  Node_XY_20b.fromC(C.Node_XY_20b nodeXY20b) {
    x = Offset_B10(nodeXY20b.x);
    y = Offset_B10(nodeXY20b.y);
  }

  @override
  List<double> getOffsetMeters() {
    return [x.offset_B10 / 100.0, y.offset_B10 / 100.0];
  }
}
