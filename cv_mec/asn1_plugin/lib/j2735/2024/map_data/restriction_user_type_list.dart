import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/map_data/restriction_user_type.dart';

class RestrictionUserTypeList {
  late List<RestrictionUserType> restrictionUserTypeList;

  RestrictionUserTypeList.fromC(C.RestrictionUserTypeList c_restrictionUserTypeList) {
    restrictionUserTypeList = [];
    for (int i = 0; i < c_restrictionUserTypeList.list.count; i++) {
      restrictionUserTypeList.add(RestrictionUserType.fromC(c_restrictionUserTypeList.list.array[i].ref));
    }
  }
}
