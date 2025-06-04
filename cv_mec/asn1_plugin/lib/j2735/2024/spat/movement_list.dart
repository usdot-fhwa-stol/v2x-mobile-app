import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/spat/movement_state.dart';

class MovementList {
  late List<MovementState> movementList;

  MovementList.fromC(C.MovementList c_movementList) {
    movementList = [];

    for (int i = 0; i < c_movementList.list.count; i++) {
      movementList.add(MovementState.fromC(c_movementList.list.array[i].ref));
    }
  }
}
