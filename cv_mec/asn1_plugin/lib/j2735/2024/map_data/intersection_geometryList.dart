import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/map_data/intersection_geometry.dart';

class IntersectionGeometryList {
  late List<IntersectionGeometry> intersectionGeometryList;

  IntersectionGeometryList.fromC(C.IntersectionGeometryList c_list) {
    intersectionGeometryList = [];
    for (int i = 0; i < c_list.list.count; i++) {
      intersectionGeometryList.add(IntersectionGeometry.fromC(c_list.list.array[i].ref));
    }
  }
}
