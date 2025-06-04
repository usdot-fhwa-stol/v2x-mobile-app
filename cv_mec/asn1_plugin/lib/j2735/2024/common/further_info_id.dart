import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/choice/choice_msg_id.dart';

class FurtherInfoId extends Choice_MsgID {
  late List<int> furtherInfoID;

  FurtherInfoId.fromOctetString(C.OCTET_STRING string) {
    furtherInfoID = string.buf.asTypedList(string.size);
  }
}
