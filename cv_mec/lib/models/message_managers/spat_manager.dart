import 'package:asn1_plugin/j2735/2024/common/intersection_reference_id.dart';
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/spat/intersection_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_event.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_state.dart';
import 'package:asn1_plugin/j2735/2024/spat/spat.dart';
import 'package:cv_mec/models/light_change_time.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:get/get.dart';

class SpatManager {
  Map<int, Spat> storedSpats = <int, Spat>{};
  Map<int, IntersectionState> storedIntersections = <int, IntersectionState>{};
  Timing timingService = Get.find<Timing>();

  void addOrUpdate(Spat spat) {

    for (IntersectionState state in spat.intersections.intersectionStateList) {
      int stateId = state.id.id.intersectionID;

      
      
      if(state.moy == null){
        DateTime now = timingService.getTime(); 
        if(state.timeStamp != null){
          DateTime yearStart = DateTime.utc(now.year, 1, 1);
          int minutes = now.difference(yearStart).inMinutes;
          if(state.timeStamp!.dSecond > 55 && now.second < 5){
            minutes -=1;
          }
          state.moy = MinuteOfTheYear(minutes);
        }
      }

      if (storedIntersections.containsKey(stateId)) {
        if (state.getUtcTime().isAfter(storedIntersections[stateId]!.getUtcTime())) {
          storedSpats[stateId] = spat;
          storedIntersections[stateId] = state;
        }
      } else {
        storedSpats[stateId] = spat;
        storedIntersections[stateId] = state;
      }
    }
  }

  void removeSpatByIntersectionReference(IntersectionReferenceID spatKey) {
    if (storedSpats.containsKey(spatKey)) {
      storedSpats.remove(spatKey);
    }

    if (storedIntersections.containsKey(spatKey)) {
      storedIntersections.remove(spatKey);
    }
  }

  void removeSpat(Spat spat) {
    for (IntersectionState state in spat.intersections.intersectionStateList) {
      if (storedIntersections.containsKey(state.id)) {
        storedIntersections.remove(state.id);
      }

      if (storedSpats.containsKey(state.id)) {
        storedSpats.remove(state.id);
      }
    }
  }

  List<IntersectionState> getActiveSpats(int spatKey, DateTime now) {
    List<IntersectionState> states = [];

    if (storedSpats.containsKey(spatKey)) {
      Spat spat = storedSpats[spatKey]!;

      for (IntersectionState state in spat.intersections.intersectionStateList) {
        if (state.getUtcTime().isAfter(now.subtract(const Duration(seconds: 30))) &&
            state.getUtcTime().isBefore(now.add(const Duration(seconds: 30)))) {
          states.add(state);
        }
      }
    }
    return states;
  }

  LightChangeTime? getNextLaneTimeChange(int intersectionId, int signalGroup, DateTime now) {
    List<IntersectionState> states = getActiveSpats(intersectionId, now);

    for (IntersectionState state in states) {
      if (state.moy != null) {
        for (MovementState movement in state.states.movementList) {
          if (movement.signalGroup.signalGroupID == signalGroup) {
            for (MovementEvent movementEvent in movement.state_time_speed.movementEventList) {
              if (movementEvent.timing != null) {
                return LightChangeTime(movementEvent.timing!, state.getUtcTime(), movementEvent.eventState);
              }
            }
          }
        }
      }
    }
    return null;
  }
}
