import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/radius_of_curvature.dart';
import 'package:asn1_plugin/j2735/2024/spat/confidence.dart';

class PathPrediction {
  late RadiusOfCurvature radiusOfCurve;
  late Confidence confidence;

  PathPrediction.fromC(C.PathPrediction c_pathPrediction) {
    radiusOfCurve = RadiusOfCurvature(c_pathPrediction.radiusOfCurve);
    confidence = Confidence(c_pathPrediction.confidence);
  }
}
