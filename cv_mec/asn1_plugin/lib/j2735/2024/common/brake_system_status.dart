import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/anti_lock_brake_status.dart';
import 'package:asn1_plugin/j2735/2024/common/auxiliary_brake_status.dart';
import 'package:asn1_plugin/j2735/2024/common/brake_applied_status.dart';
import 'package:asn1_plugin/j2735/2024/common/brake_boost_applied.dart';
import 'stability_control_status.dart';
import 'traction_control_status.dart';

class BrakeSystemStatus {
  late BrakeAppliedStatus wheelBrakes;
  late TractionControlStatus traction;
  late AntiLockBrakeStatus abs;
  late StabilityControlStatus scs;
  late BrakeBoostApplied brakeBoost;
  late AuxiliaryBrakeStatus auxBrakes;

  BrakeSystemStatus.fromC(C.BrakeSystemStatus brakeSystemStatus) {
    wheelBrakes = BrakeAppliedStatus.fromBitString(brakeSystemStatus.wheelBrakes);
    traction = TractionControlStatus.values[brakeSystemStatus.traction];
    abs = AntiLockBrakeStatus.values[brakeSystemStatus.abs];
    scs = StabilityControlStatus.values[brakeSystemStatus.scs];
    brakeBoost = BrakeBoostApplied.values[brakeSystemStatus.brakeBoost];
    auxBrakes = AuxiliaryBrakeStatus.values[brakeSystemStatus.auxBrakes];
  }
}
