import 'package:asn1_plugin/j2735/2024/spat/movement_phase_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/time_change_details.dart';

class LightChangeTime {
  late DateTime minEndTime;
  DateTime? maxEndTime;
  DateTime? likelyTime;
  late MovementPhaseState currentPhaseState;

  LightChangeTime(TimeChangeDetails timeChangeDetails, DateTime referenceTime, MovementPhaseState state) {
    currentPhaseState = state;
    minEndTime = timeChangeDetails.minEndTime.getUtcTime(referenceTime);

    if (timeChangeDetails.maxEndTime != null) {
      maxEndTime = timeChangeDetails.maxEndTime!.getUtcTime(referenceTime);
    }

    if (timeChangeDetails.likelyTime != null) {
      likelyTime = timeChangeDetails.likelyTime!.getUtcTime(referenceTime);
    }
  }
}
