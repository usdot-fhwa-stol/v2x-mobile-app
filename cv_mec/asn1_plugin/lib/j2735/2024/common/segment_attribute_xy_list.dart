import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/segment_attribute_xy.dart';
import 'dart:ffi';

class SegmentAttributeXYList {
  late List<SegmentAttributeXY> segmentAttributeXYList;

  SegmentAttributeXYList.fromC(C.SegmentAttributeXYList segmentList) {
    segmentAttributeXYList = [];
    for (int i = 0; i < segmentList.list.count; i++) {
      segmentAttributeXYList.add(SegmentAttributeXY.values[segmentList.list.array[i].value]);
    }
  }
}
