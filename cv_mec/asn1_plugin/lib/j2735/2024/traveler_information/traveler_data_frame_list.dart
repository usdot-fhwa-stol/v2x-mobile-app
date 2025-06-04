import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';

class TravelerDataFrameList {
  late List<TravelerDataFrame> travelerDataFrameList;

  TravelerDataFrameList(List<TravelerDataFrame> list) {
    travelerDataFrameList = list;
  }

  TravelerDataFrameList.empty() {
    travelerDataFrameList = [];
  }

  TravelerDataFrameList.fromC(C.TravelerDataFrameList c_dataFrames) {
    travelerDataFrameList = [];
    for (int i = 0; i < c_dataFrames.list.count; i++) {
      travelerDataFrameList.add(TravelerDataFrame.fromC(c_dataFrames.list.array[i].ref));
    }
  }
}
