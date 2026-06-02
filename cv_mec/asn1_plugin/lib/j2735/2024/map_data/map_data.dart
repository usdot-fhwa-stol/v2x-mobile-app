import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/map_data/data_parameters.dart';
import 'package:asn1_plugin/j2735/2024/map_data/intersection_geometryList.dart';
import 'package:asn1_plugin/j2735/2024/map_data/layer_id.dart';
import 'package:asn1_plugin/j2735/2024/map_data/layer_type.dart';
import 'package:asn1_plugin/j2735/2024/map_data/restriction_class_list.dart';
import 'package:asn1_plugin/j2735/2024/map_data/road_segment_list.dart';

class MapData {
  MinuteOfTheYear? timeStamp;

  late MsgCount msgIssueRevision;
  LayerType? layerType;
  LayerID? layerID;
  IntersectionGeometryList? intersections;
  RoadSegmentList? roadSegments;
  DataParameters? dataParameters;
  RestrictionClassList? restrictionList;

  MapData.fromC(C.MapData c_map) {

    if (c_map.timeStamp.address != 0) {
      timeStamp = MinuteOfTheYear(c_map.timeStamp.value);
    }
    
    msgIssueRevision = MsgCount(c_map.msgIssueRevision);

    if (c_map.layerType.address != 0) {
      layerType = LayerType.values[c_map.layerType.value];
    }

    if (c_map.layerID.address != 0) {
      layerID = LayerID(c_map.layerID.value);
    }

    if(c_map.intersections.address != 0){
      intersections = IntersectionGeometryList.fromC(c_map.intersections.ref);
    }

    if (c_map.roadSegments.address != 0) {
      roadSegments = RoadSegmentList.fromC(c_map.roadSegments.ref);
    }

    if (c_map.dataParameters.address != 0) {
      dataParameters = DataParameters.fromC(c_map.dataParameters.ref);
    }
    
    if (c_map.restrictionList.address != 0) {
      restrictionList = RestrictionClassList.fromC(c_map.restrictionList.ref);
    }
  }
}
