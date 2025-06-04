import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_description.dart';
import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:asn1_plugin/j2735/2024/common/lane_width.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/common/regional_extension.dart';
import 'package:asn1_plugin/j2735/2024/common/road_segment_reference_id.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/direction_of_use.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/geometric_projection.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/offset_system.dart';

class GeographicalPath {
  DescriptiveName? name;
  RoadSegmentReferenceID? id;
  Position3D? anchor;
  LaneWidth? laneWidth;
  DirectionOfUse? directionality;
  bool? closedPath;
  HeadingSlice? direction;
  Choice_Description? description;
  List<RegionalExtension>? regional;

  GeographicalPath.fromC(C.GeographicalPath geographicalPath) {
    if (geographicalPath.name.address != 0) {
      name = DescriptiveName.fromOctetString(geographicalPath.name.ref);
    }

    if (geographicalPath.id.address != 0) {
      id = RoadSegmentReferenceID.fromC(geographicalPath.id.ref);
    }

    if (geographicalPath.anchor.address != 0) {
      anchor = Position3D.fromC(geographicalPath.anchor.ref);
    }

    if (geographicalPath.laneWidth.address != 0) {
      laneWidth = LaneWidth(geographicalPath.laneWidth.value);
    }

    if (geographicalPath.directionality.address != 0) {
      directionality = DirectionOfUse.values[geographicalPath.directionality.value];
    }

    if (geographicalPath.closedPath.address != 0) {
      closedPath = geographicalPath.closedPath.value == 0;
    }

    if (geographicalPath.direction.address != 0) {
      direction = HeadingSlice.fromBitString(geographicalPath.direction.ref);
    }

    if (geographicalPath.description.address != 0) {
      int choiceDescriptionID = geographicalPath.description.ref.present;
      if (choiceDescriptionID == C.GeographicalPath__description_PR.GeographicalPath__description_PR_path) {
        description = OffsetSystem.fromC(geographicalPath.description.ref.choice.path);
      } else if (choiceDescriptionID == C.GeographicalPath__description_PR.GeographicalPath__description_PR_geometry) {
        description = GeometricProjection.fromC(geographicalPath.description.ref.choice.geometry);
      } else if (choiceDescriptionID == C.GeographicalPath__description_PR.GeographicalPath__description_PR_oldRegion) {
        print("Received description of type oldRegion. This is no longer recommended for use and not supported");
        // description = ValidRegion.fromC(geographicalPath.description.ref.choice.oldRegion);
      }
    }

    // if(geographicalPath.regional.address != 0){
    //   regional = [];
    //   for(int i=0; i< geographicalPath.regional.ref.list.count; i++){
    //     regional.add(RegionalExtension.fromC(geographicalPath.regional.ref.list.array[i]));
    //   }
    // }
  }
}
