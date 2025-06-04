import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/map_data/generic_lane.dart';

class RoadLaneSetList {
  late List<GenericLane> roadLaneSetList;

  RoadLaneSetList.fromC(C.RoadLaneSetList c_roadLaneSetList) {
    roadLaneSetList = [];
    for (int i = 0; i < c_roadLaneSetList.list.count; i++) {
      roadLaneSetList.add(GenericLane.fromC(c_roadLaneSetList.list.array[i].ref));
    }
  }
}
