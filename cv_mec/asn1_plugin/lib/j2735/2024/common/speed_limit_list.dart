import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/choice/choice_lane_data_attribute.dart';
import 'package:asn1_plugin/j2735/2024/common/regulatory_speed_limit.dart';

class SpeedLimitList extends Choice_LaneDataAttribute {
  late List<RegulatorySpeedLimit> speedLimitList;

  SpeedLimitList.fromC(C.SpeedLimitList speedList) {
    speedLimitList = [];
    for (int i = 0; i < speedList.list.count; i++) {
      speedLimitList.add(RegulatorySpeedLimit.fromC(speedList.list.array[i].ref));
    }
  }
}
