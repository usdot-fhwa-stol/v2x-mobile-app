import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/regional_extension.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame_list.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/unique_msg_id.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/url_base.dart';

class TravelerInformation {
  late MsgCount msgCnt;
  MinuteOfTheYear? timestamp;
  UniqueMSGID? packetID;
  URL_Base? urlB;

  late TravelerDataFrameList dataFrames;

  late List<RegionalExtension> regional;

  TravelerInformation.fromC(C.TravelerInformation c_tim) {
    msgCnt = MsgCount(c_tim.msgCnt);

    if (c_tim.timeStamp.address != 0) {
      timestamp = MinuteOfTheYear(c_tim.timeStamp.value);
    } else {
      timestamp = null;
    }

    if (c_tim.packetID.address != 0) {
      packetID = UniqueMSGID.fromOctetString(c_tim.packetID.ref);
    } else {
      packetID = null;
    }

    if (c_tim.urlB.address != 0) {
      urlB = URL_Base.fromOctetString(c_tim.urlB.ref);
    } else {
      urlB = null;
    }

    dataFrames = TravelerDataFrameList.fromC(c_tim.dataFrames);

    // this.regional = RegionalExtension.fromC(c_tim.regional);
  }
}
