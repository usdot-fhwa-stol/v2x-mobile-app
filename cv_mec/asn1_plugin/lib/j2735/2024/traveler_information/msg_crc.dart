import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;

class MsgCRC {
  late List<int> msgCRC;

  MsgCRC.fromOctetString(C.OCTET_STRING string){
    msgCRC = string.buf.asTypedList(string.size);
  }
}