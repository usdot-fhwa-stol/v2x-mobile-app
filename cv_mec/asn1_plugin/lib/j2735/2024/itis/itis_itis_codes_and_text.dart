import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';

import 'package:asn1_plugin/j2735/2024/choice/choice_content.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_codes.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_text.dart';

class ITIS_ITIScodesAndText extends Choice_Content {
  late List<Choice_Item> item;

  ITIS_ITIScodesAndText.fromC(C.ITIS_ITIScodesAndText itisCodesAndText) {
    item = [];
    for (int i = 0; i < itisCodesAndText.list.count; i++) {
      if (itisCodesAndText.list.array[i].ref.item.present ==
          C.ITIS_ITIScodesAndText__Member__item_PR.ITIS_ITIScodesAndText__Member__item_PR_itis) {
        item.add(ITIScodes(itisCodesAndText.list.array[i].ref.item.choice.itis));
      } else if (itisCodesAndText.list.array[i].ref.item.present ==
          C.ITIS_ITIScodesAndText__Member__item_PR.ITIS_ITIScodesAndText__Member__item_PR_text) {
        item.add(ITIStext.fromOctetString(itisCodesAndText.list.array[i].ref.item.choice.text));
      }
    }
  }
}
