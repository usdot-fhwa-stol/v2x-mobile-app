import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/map_data/restriction_applies_to.dart';

class RestrictionUserType {
  RestrictionAppliesTo? basicType;

  RestrictionUserType.fromC(C.RestrictionUserType c_restrictionUserType) {
    if (c_restrictionUserType.present == 0) {
      basicType = RestrictionAppliesTo.values[c_restrictionUserType.choice.basicType];
    }
  }
}
