import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_xy.dart';
import 'package:asn1_plugin/j2735/2024/common/offset_b16.dart';

class Node_XY_32b extends Choice_NodeOffsetPointXY {
  late Offset_B16 x;
  late Offset_B16 y;

  Node_XY_32b.fromC(C.Node_XY_32b nodeXY32b) {
    x = Offset_B16(nodeXY32b.x);
    y = Offset_B16(nodeXY32b.y);
  }

  @override
  List<double> getOffsetMeters() {
    return [x.offset_B16 / 100.0, y.offset_B16 / 100.0];
  }
}
