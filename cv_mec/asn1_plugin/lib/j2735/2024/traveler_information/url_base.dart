import 'package:asn1_plugin/generated_bindings.dart';

class URL_Base {
  late String url_Base;

  URL_Base(this.url_Base);

  URL_Base.fromOctetString(OCTET_STRING string){
    url_Base = string.buf.toString();
  }

  URL_Base.empty() : url_Base = "";
}