import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart';

class TemporaryID{
  late List<int> temporaryID;

  TemporaryID.fromOctetString(OCTET_STRING string){
    temporaryID = string.buf.asTypedList(string.size);
  }


  void toOctetString(OCTET_STRING string){
    for (int i = 0; i < temporaryID.length; i++) {
      string.buf[i] = temporaryID[i];
    }
    // string.size = temporaryID.length;
  }
}