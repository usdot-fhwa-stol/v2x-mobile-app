import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/choice/choice_msg_id.dart';
import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/msg_crc.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/mutcd_code.dart';

class RoadSignID extends Choice_MsgID {
  late Position3D position;
  late HeadingSlice viewAngle;
  MUTCDCode? mutcdCode;
  MsgCRC? crc;

  RoadSignID.fromC(C.RoadSignID roadSignID) {
    position = Position3D.fromC(roadSignID.position);
    viewAngle = HeadingSlice.fromBitString(roadSignID.viewAngle);

    if (roadSignID.mutcdCode.address != 0) {
      mutcdCode = MUTCDCode.values[roadSignID.mutcdCode.value];
    }

    if (roadSignID.crc.address != 0) {
      crc = MsgCRC.fromOctetString(roadSignID.crc.ref);
    }
  }
}
