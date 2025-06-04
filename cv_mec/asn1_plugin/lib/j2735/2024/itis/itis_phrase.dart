import 'package:asn1_plugin/generated_bindings.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';

class ITISPhrase extends Choice_Item {
  late String itisPhrase;

  ITISPhrase(this.itisPhrase);

  ITISPhrase.fromOctetString(OCTET_STRING string) {
    itisPhrase = string.toString();
  }
}
