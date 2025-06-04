import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/spat/movement_phase_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/time_change_details.dart';
import 'package:asn1_plugin/j2735/2024/spat/advisory_speed_list.dart';

class MovementEvent {
  late MovementPhaseState eventState;
  TimeChangeDetails? timing;
  AdvisorySpeedList? speeds;

  MovementEvent.fromC(C.MovementEvent c_movementEvent) {
    eventState = MovementPhaseState.values[c_movementEvent.eventState];

    if (c_movementEvent.timing.address != 0) {
      timing = TimeChangeDetails.fromC(c_movementEvent.timing.ref);
    }

    if (c_movementEvent.speeds.address != 0) {
      speeds = AdvisorySpeedList.fromC(c_movementEvent.speeds.ref);
    }
  }
}
