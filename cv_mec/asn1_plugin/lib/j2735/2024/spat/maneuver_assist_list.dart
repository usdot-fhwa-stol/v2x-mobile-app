import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/spat/connection_maneuver_assist.dart';

class ManeuverAssistList {
  late List<ConnectionManeuverAssist> maneuverAssistList;

  ManeuverAssistList.fromC(C.ManeuverAssistList c_maneuverAssistList) {
    maneuverAssistList = [];
    for (int i = 0; i < c_maneuverAssistList.list.count; i++) {
      maneuverAssistList.add(ConnectionManeuverAssist.fromC(c_maneuverAssistList.list.array[i].ref));
    }
  }
}
