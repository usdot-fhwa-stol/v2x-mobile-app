import 'package:asn1_plugin/generated_bindings.dart';

class URL_Short{
  late String url_Short;

  URL_Short(this.url_Short);

  URL_Short.fromOctetString(OCTET_STRING string){
    url_Short = string.toString();
  }

}