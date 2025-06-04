import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/road_regulator_id.dart';
import 'package:asn1_plugin/j2735/2024/common/road_segment_id.dart';

class RoadSegmentReferenceID {
  RoadRegulatorID? region;
  late RoadSegmentID id;

  RoadSegmentReferenceID.fromC(C.RoadSegmentReferenceID roadSegmentReferenceID) {
    if (roadSegmentReferenceID.region.address != 0) {
      region = RoadRegulatorID(roadSegmentReferenceID.region.value);
    }

    id = RoadSegmentID(roadSegmentReferenceID.id);
  }
}
