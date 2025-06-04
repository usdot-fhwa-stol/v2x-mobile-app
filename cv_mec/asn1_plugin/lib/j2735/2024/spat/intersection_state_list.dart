import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/spat/intersection_state.dart';

class IntersectionStateList {
  late List<IntersectionState> intersectionStateList;

  IntersectionStateList.fromC(C.IntersectionStateList c_intersectionStateList) {
    intersectionStateList = [];
    for (int i = 0; i < c_intersectionStateList.list.count; i++) {
      intersectionStateList.add(IntersectionState.fromC(c_intersectionStateList.list.array[i].ref));
    }
  }
}
