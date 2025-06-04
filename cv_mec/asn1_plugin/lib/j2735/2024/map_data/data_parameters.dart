import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:asn1_plugin/generated_bindings.dart' as C;

class DataParameters {
  String? processMethod;
  String? processAgency;
  String? lastCheckedDate;
  String? geoidUsed;

  DataParameters.fromC(C.DataParameters c_dataParameters) {
    if (c_dataParameters.processMethod != 0) {
      processMethod = octetStringToString(c_dataParameters.processMethod.ref);
    }

    if (c_dataParameters.processAgency != 0) {
      processAgency = octetStringToString(c_dataParameters.processAgency.ref);
    }

    if (c_dataParameters.lastCheckedDate != 0) {
      lastCheckedDate =
          octetStringToString(c_dataParameters.lastCheckedDate.ref);
    }

    if (c_dataParameters.geoidUsed != 0) {
      geoidUsed = octetStringToString(c_dataParameters.geoidUsed.ref);
    }
  }

  String octetStringToString(C.OCTET_STRING string) {
    final Uint8List byteList = string.buf.asTypedList(string.size);
    return utf8.decode(byteList);
  }
}
