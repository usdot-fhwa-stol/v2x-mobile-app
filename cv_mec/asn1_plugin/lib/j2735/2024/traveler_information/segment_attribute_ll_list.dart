import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/traveler_information/segment_attribute_ll.dart';

class SegmentAttributeLLList {
  late List<SegmentAttributeLL> segmentAttributeLLList;

  SegmentAttributeLLList.fromC(C.SegmentAttributeLLList segmentAttributeList) {
    for (int i = 0; i < segmentAttributeList.list.count; i++) {
      segmentAttributeLLList.add(SegmentAttributeLL.values[segmentAttributeList.list.array[i].value]);
    }
  }
}
