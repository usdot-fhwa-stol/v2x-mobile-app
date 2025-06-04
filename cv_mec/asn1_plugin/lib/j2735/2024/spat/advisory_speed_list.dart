import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/spat/advisory_speed.dart';

class AdvisorySpeedList {
  late List<AdvisorySpeed> advisorySpeedList;

  AdvisorySpeedList.fromC(C.AdvisorySpeedList c_advistorySpeedList) {
    advisorySpeedList = [];

    for (int i = 0; i < c_advistorySpeedList.list.count; i++) {
      advisorySpeedList.add(AdvisorySpeed.fromC(c_advistorySpeedList.list.array[i].ref));
    }
  }
}
