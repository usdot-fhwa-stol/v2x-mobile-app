import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/choice/choice_content.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_msg_id.dart';
import 'package:asn1_plugin/j2735/2024/common/d_year.dart';
import 'package:asn1_plugin/j2735/2024/common/further_info_id.dart';
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_limit.dart';
import 'package:asn1_plugin/j2735/2024/common/sspindex.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_itis_codes_and_text.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/exit_service.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/generic_signage.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/geographical_path.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/minutes_duration.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/road_sign_id.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/sign_priority.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame_new_part_iiicontent.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_info_type.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/url_short.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/work_zone.dart';

class TravelerDataFrame {
  late SSPindex doNotUse1;
  late TravelerInfoType frameType;
  late Choice_MsgID msgId;
  DYear? startYear;
  late MinuteOfTheYear startTime;
  late MinutesDuration durationTime;
  late SignPriority priority;
  late SSPindex doNotUse2;
  late List<GeographicalPath> regions;
  late SSPindex doNotUse3;
  late SSPindex doNotUse4;
  late Choice_Content content;
  URL_Short? url;

  late TravelerDataFrameNewPartIIIContent contentNew;

  TravelerDataFrame.fromC(C.TravelerDataFrame c_dataFrame) {
    doNotUse1 = SSPindex(0);

    // Set Frame Type
    frameType = TravelerInfoType.values[c_dataFrame.frameType];

    // Set Message Choice
    int msgChoiceID = c_dataFrame.msgId.present;
    if (msgChoiceID == 1) {
      msgId = FurtherInfoId.fromOctetString(c_dataFrame.msgId.choice.furtherInfoID);
    } else if (msgChoiceID == 2) {
      msgId = RoadSignID.fromC(c_dataFrame.msgId.choice.roadSignID);
    } else {
      print("Tim has Invalid Choice ${c_dataFrame.msgId.present} for MsgID.");
    }

    // Set D Year
    if (c_dataFrame.startYear.address != 0) {
      startYear = DYear(c_dataFrame.startYear.value);
    }

    // Set Start Time
    startTime = MinuteOfTheYear(c_dataFrame.startTime);

    // Set Duration Time
    durationTime = MinutesDuration(c_dataFrame.durationTime);

    // Set Sign Priority
    priority = SignPriority(c_dataFrame.priority);

    doNotUse2 = SSPindex(0);

    // Set Geographical Paths
    regions = [];
    for (int i = 0; i < c_dataFrame.regions.list.count; i++) {
      regions.add(GeographicalPath.fromC(c_dataFrame.regions.list.array[i].ref));
    }

    doNotUse3 = SSPindex(0);
    doNotUse4 = SSPindex(0);

    // Set Content
    int contentChoiceID = c_dataFrame.content.present;
    if (contentChoiceID == 1) {
      content = ITIS_ITIScodesAndText.fromC(c_dataFrame.content.choice.advisory);
    } else if (contentChoiceID == 2) {
      content = WorkZone.fromC(c_dataFrame.content.choice.workZone);
    } else if (contentChoiceID == 3) {
      content = GenericSignage.fromC(c_dataFrame.content.choice.genericSign);
    } else if (contentChoiceID == 4) {
      content = SpeedLimit.fromC(c_dataFrame.content.choice.speedLimit);
    } else if (contentChoiceID == 5) {
      content = ExitService.fromC(c_dataFrame.content.choice.exitService);
    } else {}

    if (c_dataFrame.url.address != 0) {
      url = URL_Short.fromOctetString(c_dataFrame.url.ref);
    }
  }
}
