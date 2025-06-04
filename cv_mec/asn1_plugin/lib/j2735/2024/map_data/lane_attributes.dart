import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_lane_type_attributes.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_barrier.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_bike.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_crosswalk.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_parking.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_sidewalk.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_striping.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_tracked_vehicle.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_attributes_vehicle.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_direction.dart';
import 'package:asn1_plugin/j2735/2024/map_data/lane_sharing.dart';

class LaneAttributes {
  late LaneDirection directionalUse;
  late LaneSharing sharedWith;
  late Choice_LaneTypeAttributes laneType;

  LaneAttributes.fromC(C.LaneAttributes c_laneAttributes) {
    directionalUse = LaneDirection.fromBitString(c_laneAttributes.directionalUse);

    sharedWith = LaneSharing.fromBitString(c_laneAttributes.sharedWith);

    if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_vehicle) {
      laneType = LaneAttributesVehicle.fromBitString(c_laneAttributes.laneType.choice.vehicle);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_crosswalk) {
      laneType = LaneAttributesCrosswalk.fromBitString(c_laneAttributes.laneType.choice.crosswalk);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_bikeLane) {
      laneType = LaneAttributesBike.fromBitString(c_laneAttributes.laneType.choice.bikeLane);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_sidewalk) {
      laneType = LaneAttributesSidewalk.fromBitString(c_laneAttributes.laneType.choice.sidewalk);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_median) {
      laneType = LaneAttributesBarrier.fromBitString(c_laneAttributes.laneType.choice.median);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_striping) {
      laneType = LaneAttributesStriping.fromBitString(c_laneAttributes.laneType.choice.striping);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_trackedVehicle) {
      laneType = LaneAttributesTrackedVehicle.fromBitString(c_laneAttributes.laneType.choice.trackedVehicle);
    } else if (c_laneAttributes.laneType.present == C.LaneTypeAttributes_PR.LaneTypeAttributes_PR_parking) {
      laneType = LaneAttributesParking.fromBitString(c_laneAttributes.laneType.choice.parking);
    }
  }
}
