import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/common/intersection_reference_id.dart';
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/road_authority_id.dart';
import 'package:asn1_plugin/j2735/2024/spat/enabled_lane_list.dart';
import 'package:asn1_plugin/j2735/2024/spat/intersection_status_object.dart';
import 'package:asn1_plugin/j2735/2024/spat/maneuver_assist_list.dart';
import 'package:asn1_plugin/j2735/2024/spat/movement_list.dart';
import 'package:asn1_plugin/j2735/2024/common/d_second.dart';

class IntersectionState {
  DescriptiveName? name;
  late IntersectionReferenceID id;
  late MsgCount revision;
  late IntersectionStatusObject status;
  MinuteOfTheYear? moy;
  DSecond? timeStamp;
  EnabledLaneList? enabledLanes;
  late MovementList states;
  ManeuverAssistList? maneuverAssistList;
  RoadAuthorityID? roadAuthorityID;

  IntersectionState.fromC(C.IntersectionState c_intersectionState) {
    if (c_intersectionState.name.address != 0) {
      name = DescriptiveName.fromOctetString(c_intersectionState.name.ref);
    }

    id = IntersectionReferenceID.fromC(c_intersectionState.id);

    revision = MsgCount(c_intersectionState.revision);

    status = IntersectionStatusObject.fromBitString(c_intersectionState.status);
    if (c_intersectionState.moy.address != 0) {
      moy = MinuteOfTheYear(c_intersectionState.moy.value);
    }

    if (c_intersectionState.timeStamp.address != 0) {
      timeStamp = DSecond(c_intersectionState.timeStamp.value);
    }

    if (c_intersectionState.enabledLanes.address != 0) {
      enabledLanes = EnabledLaneList.fromC(c_intersectionState.enabledLanes.ref);
    }

    states = MovementList.fromC(c_intersectionState.states);

    if (c_intersectionState.maneuverAssistList.address != 0) {
      maneuverAssistList = ManeuverAssistList.fromC(c_intersectionState.maneuverAssistList.ref);
    }

    if (c_intersectionState.roadAuthorityID.address != 0) {
      roadAuthorityID = RoadAuthorityID.fromC(c_intersectionState.roadAuthorityID.ref);
    }
  }

  DateTime getUtcTime() {
    int year = DateTime.now().year;

    DateTime time = DateTime.utc(year, 1, 1);

    if (moy != null) {
      time = time.add(Duration(minutes: moy!.minuteOfTheYear));
    }

    if (timeStamp != null) {
      time = time.add(Duration(milliseconds: timeStamp!.dSecond));
    }

    return time;
  }
}
