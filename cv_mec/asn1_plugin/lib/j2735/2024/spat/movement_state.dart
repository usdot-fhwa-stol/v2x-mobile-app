import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/common/signal_group_id.dart';
import 'package:asn1_plugin/j2735/2024/spat/maneuver_assist_list.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_event_list.dart';

class MovementState {
  DescriptiveName? movementName;
  late SignalGroupID signalGroup;
  late MovementEventList state_time_speed;
  ManeuverAssistList? maneuverAssistList;

  MovementState.fromC(C.MovementState c_movementState) {
    if (c_movementState.movementName.address != 0) {
      movementName = DescriptiveName.fromOctetString(c_movementState.movementName.ref);
    }

    signalGroup = SignalGroupID(c_movementState.signalGroup);

    state_time_speed = MovementEventList.fromC(c_movementState.state_time_speed);

    if (c_movementState.maneuverAssistList.address != 0) {
      maneuverAssistList = ManeuverAssistList.fromC(c_movementState.maneuverAssistList.ref);
    }
  }
}
