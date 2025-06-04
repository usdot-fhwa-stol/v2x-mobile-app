import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/map_data/connection.dart';

class ConnectsToList {
  late List<Connection> connectsTo;

  ConnectsToList.fromC(C.ConnectsToList c_connectsTo) {
    connectsTo = [];
    for (int i = 0; i < c_connectsTo.list.count; i++) {
      connectsTo.add(Connection.fromC(c_connectsTo.list.array[i].ref));
    }
  }
}
