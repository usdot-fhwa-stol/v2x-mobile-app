import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/intersection_reference_id.dart';
import 'package:asn1_plugin/j2735/2024/common/lane_connection_id.dart';
import 'package:asn1_plugin/j2735/2024/common/signal_group_id.dart';
import 'package:asn1_plugin/j2735/2024/map_data/connecting_lane.dart';
import 'package:asn1_plugin/j2735/2024/map_data/restriction_class_id.dart';

class Connection {
  late ConnectingLane connectingLane;
  IntersectionReferenceID? remoteIntersection;
  SignalGroupID? signalGroup;
  RestrictionClassID? userClass;
  LaneConnectionID? connectionID;

  Connection.fromC(C.Connection c_connection) {
    connectingLane = ConnectingLane.fromC(c_connection.connectingLane);

    if (c_connection.remoteIntersection.address != 0) {
      remoteIntersection = IntersectionReferenceID.fromC(c_connection.remoteIntersection.ref);
    }

    if (c_connection.signalGroup.address != 0) {
      signalGroup = SignalGroupID(c_connection.signalGroup.value);
    }

    if (c_connection.userClass.address != 0) {
      signalGroup = SignalGroupID(c_connection.userClass.value);
    }

    if (c_connection.connectionID.address != 0) {
      connectionID = LaneConnectionID(c_connection.connectionID.value);
    }
  }
}
