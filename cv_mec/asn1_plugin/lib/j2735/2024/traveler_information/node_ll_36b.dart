import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_node_offset_point_ll.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/offset_ll_b12.dart';

class Node_LL_36B extends Choice_NodeOffsetPointLL {
  late OffsetLL_B12 lon;
  late OffsetLL_B12 lat;

  Node_LL_36B.fromC(C.Node_LL_36B nodeLL36b) {
    lon = OffsetLL_B12(nodeLL36b.lon);
    lat = OffsetLL_B12(nodeLL36b.lat);
  }

  @override
  List<double> getOffsetLongLat() {
    return [lon.offsetLL_B12 / 1E7, lat.offsetLL_B12 / 1E7];
  }
}
