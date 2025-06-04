import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart';

class UniqueMSGID{
  late List<int> uniqueMSGID;

  UniqueMSGID.fromOctetString(OCTET_STRING string){
    uniqueMSGID = string.buf.asTypedList(string.size);
  }

  UniqueMSGID.empty() : uniqueMSGID = List.generate(4, (_) => 0);
}