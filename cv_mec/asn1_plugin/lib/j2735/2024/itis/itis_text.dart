import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1_plugin/generated_bindings.dart';
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';

class ITIStext extends Choice_Item {
  late String itisText;

  ITIStext(this.itisText);

  ITIStext.fromOctetString(OCTET_STRING string) {
    // itisText = String.from
    final Uint8List byteList = string.buf.asTypedList(string.size);

    // Convert the byte list to a String (assuming UTF-8 encoding)
    itisText = utf8.decode(byteList);
  }
}
