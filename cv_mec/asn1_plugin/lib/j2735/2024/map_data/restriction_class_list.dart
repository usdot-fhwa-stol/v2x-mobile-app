import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/map_data/restriction_class_assignment.dart';

class RestrictionClassList {
  late List<RestrictionClassAssignment> restrictionClassList;

  RestrictionClassList.fromC(C.RestrictionClassList c_restrictionClassList) {
    restrictionClassList = [];
    for (int i = 0; i < c_restrictionClassList.list.count; i++) {
      restrictionClassList.add(RestrictionClassAssignment.fromC(c_restrictionClassList.list.array[i].ref));
    }
  }
}
