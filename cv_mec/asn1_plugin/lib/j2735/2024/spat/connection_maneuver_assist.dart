import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/common/lane_connection_id.dart';
import 'package:asn1_plugin/j2735/2024/spat/pedestrian_bicycle_detect.dart';
import 'package:asn1_plugin/j2735/2024/spat/wait_on_stop_line.dart';
import 'package:asn1_plugin/j2735/2024/spat/zone_length.dart';

class ConnectionManeuverAssist {
  late LaneConnectionID connectionID;
  ZoneLength? queueLength;
  ZoneLength? availableStorageLength;
  WaitOnStopLine? waitOnStop;
  PedestrianBicycleDetect? pedBicycleDetect;

  ConnectionManeuverAssist.fromC(C.ConnectionManeuverAssist c_connectionManeuverAssist) {
    connectionID = LaneConnectionID(c_connectionManeuverAssist.connectionID);

    if (c_connectionManeuverAssist.queueLength.address != 0) {
      queueLength = ZoneLength(c_connectionManeuverAssist.queueLength.value);
    }

    if (c_connectionManeuverAssist.availableStorageLength.address != 0) {
      availableStorageLength = ZoneLength(c_connectionManeuverAssist.availableStorageLength.value);
    }

    if (c_connectionManeuverAssist.waitOnStop.address != 0) {
      waitOnStop = WaitOnStopLine(c_connectionManeuverAssist.waitOnStop.value);
    }

    if (c_connectionManeuverAssist.pedBicycleDetect.address != 0) {
      pedBicycleDetect = PedestrianBicycleDetect(c_connectionManeuverAssist.pedBicycleDetect.value);
    }
  }
}
