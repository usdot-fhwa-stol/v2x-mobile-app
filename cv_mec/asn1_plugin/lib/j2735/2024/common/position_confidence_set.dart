import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/elevation_confidence.dart';
import 'package:asn1_plugin/j2735/2024/common/position_confidence.dart';

class PositionConfidenceSet {
  late PositionConfidence pos;
  late ElevationConfidence elevation;

  PositionConfidenceSet.fromC(C.PositionConfidenceSet c_positionConfidenceSet) {
    pos = PositionConfidence.values[c_positionConfidenceSet.pos];
    elevation = ElevationConfidence.values[c_positionConfidenceSet.elevation];
  }
}
