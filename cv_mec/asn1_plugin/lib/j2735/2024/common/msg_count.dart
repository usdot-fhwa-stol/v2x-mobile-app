import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

import 'package:asn1_plugin/j2735/2024/common/msg_count.dart' as C;

class MsgCount{
  late int msgCount;
  MsgCount(this.msgCount);

  MsgCount.empty() : msgCount = 0;

  // int toC(Pointer<C.MsgCount> pointer) {
  //   return 0;
  // }
  
}