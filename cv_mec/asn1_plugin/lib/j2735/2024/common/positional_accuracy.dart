import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/semi_major_axis_accuracy.dart';
import 'package:asn1_plugin/j2735/2024/common/semi_major_axis_orientation.dart';
import 'package:asn1_plugin/j2735/2024/common/semi_minor_axis_accuracy.dart';

class PositionalAccuracy {
  late SemiMajorAxisAccuracy semiMajor;
  late SemiMinorAxisAccuracy semiMinor;
  late SemiMajorAxisOrientation orientation;

  PositionalAccuracy.fromC(C.PositionalAccuracy accuracy) {
    semiMajor = SemiMajorAxisAccuracy(accuracy.semiMajor);
    semiMinor = SemiMinorAxisAccuracy(accuracy.semiMinor);
    orientation = SemiMajorAxisOrientation(accuracy.orientation);
  }
}
