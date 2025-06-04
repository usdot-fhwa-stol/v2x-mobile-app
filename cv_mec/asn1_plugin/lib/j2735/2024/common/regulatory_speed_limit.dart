import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/speed_limit_type.dart';
import 'package:asn1_plugin/j2735/2024/common/velocity.dart';

class RegulatorySpeedLimit {
  late SpeedLimitType type;
  late Velocity speed;

  RegulatorySpeedLimit.fromC(C.RegulatorySpeedLimit regulatorySpeedLimit) {
    type = SpeedLimitType.values[regulatorySpeedLimit.type];
    speed = Velocity(regulatorySpeedLimit.speed);
  }
}
