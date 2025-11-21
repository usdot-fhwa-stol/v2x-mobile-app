import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart';
import 'package:ffi/ffi.dart';

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

  OCTET_STRING toC(Pointer<OCTET_STRING> pointer) {
    print("Big Gorilla 1.3.1");
    final c_tempID = pointer.ref;
    print("Big Gorilla 1.3.2");
    // Free previous buffer if needed
    if (c_tempID.buf != nullptr && c_tempID.size > 0) {
      calloc.free(c_tempID.buf);
    }
    print("Big Gorilla 1.3.3");

    if (temporaryID.isEmpty) {
      c_tempID.size = 0;
      c_tempID.buf = nullptr;
      return c_tempID;
    }
    print("Big Gorilla 1.3.4");

    c_tempID.buf = calloc.allocate<Uint8>(temporaryID.length);
    print("Big Gorilla 1.3.5");
    for (int i = 0; i < temporaryID.length; i++) {
      c_tempID.buf[i] = temporaryID[i];
    }
    print("Big Gorilla 1.3.6");
    c_tempID.size = temporaryID.length;
    print("Big Gorilla 1.3.7");
    return c_tempID;
  }
}