import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/choice/choice_content.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_codes.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_text.dart';

class WorkZone extends Choice_Content {
  late List<Choice_Item> item;

  WorkZone.fromC(C.WorkZone workZone) {
    item = [];
    for (int i = 0; i < workZone.list.count; i++) {
      if (workZone.list.array[i].ref.item.present == C.WorkZone__Member__item_PR.WorkZone__Member__item_PR_itis) {
        item.add(ITIScodes(workZone.list.array[i].ref.item.choice.itis));
      } else if (workZone.list.array[i].ref.item.present ==
          C.WorkZone__Member__item_PR.WorkZone__Member__item_PR_text) {
        item.add(ITIStext.fromOctetString(workZone.list.array[i].ref.item.choice.text));
      }
    }
  }
}
