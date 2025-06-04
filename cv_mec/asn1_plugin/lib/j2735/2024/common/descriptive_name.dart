import 'dart:convert';
import 'dart:typed_data';
import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;
class DescriptiveName{
  late String descriptiveName;

  DescriptiveName.fromOctetString(C.OCTET_STRING string ){
    final Uint8List byteList = string.buf.asTypedList(string.size);

    // Convert the byte list to a String (assuming UTF-8 encoding)
    descriptiveName = utf8.decode(byteList);
  }
}