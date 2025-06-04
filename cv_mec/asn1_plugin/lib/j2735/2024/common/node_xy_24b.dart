import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/offset_b12.dart';

class Node_XY_24b extends Choice_NodeOffsetPointXY {
  late Offset_B12 x;
  late Offset_B12 y;

  Node_XY_24b.fromC(C.Node_XY_24b nodeXY24b) {
    x = Offset_B12(nodeXY24b.x);
    y = Offset_B12(nodeXY24b.y);
  }

  @override
  List<double> getOffsetMeters() {
    return [x.offset_B12 / 100.0, y.offset_B12 / 100.0];
  }
}
