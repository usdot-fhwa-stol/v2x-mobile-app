import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/choice/choice_description.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_offset.dart';
import 'package:asn1_plugin/j2735/2024/common/node_list_xy.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/node_list_ll.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/zoom.dart';

class OffsetSystem extends Choice_Description {
  Zoom? scale;
  late Choice_Offset offset;

  OffsetSystem.fromC(C.OffsetSystem offsetSystem) {
    if (offsetSystem.scale.address != 0) {
      scale = Zoom(offsetSystem.scale.value);
    }

    int choiceOffset = offsetSystem.offset.present;

    if (choiceOffset == 1) {
      offset = NodeListXY.fromC(offsetSystem.offset.choice.xy);
    } else if (choiceOffset == 2) {
      offset = NodeListLL.fromC(offsetSystem.offset.choice.ll);
    } else {
      print("Choice Offset $choiceOffset is invalid for OffsetSystem");
    }
  }
}
