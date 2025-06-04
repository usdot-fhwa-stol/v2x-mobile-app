import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/common/lane_id.dart';
import 'package:asn1_plugin/j2735/2024/map_data/allowed_maneuvers.dart';

class ConnectingLane {
  late LaneID lane;
  AllowedManeuvers? maneuver;

  ConnectingLane.fromC(C.ConnectingLane c_connectingLane) {
    lane = LaneID(c_connectingLane.lane);

    if (c_connectingLane.maneuver.address != 0) {
      maneuver = AllowedManeuvers.fromBitString(c_connectingLane.maneuver.ref);
    }
  }
}
