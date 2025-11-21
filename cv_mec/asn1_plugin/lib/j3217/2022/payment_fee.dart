import 'dart:ffi';
import 'dart:typed_data';

import 'package:asn1_plugin/generated_bindings.dart' as C;

class PaymentFee {
  late int paymentFeeAmount;
  late PayUnit paymentFeeUnit;
  PaymentFee.fromC(C.PaymentFee c_obj){
    paymentFeeAmount = c_obj.paymentFeeAmount;
    paymentFeeUnit = PayUnit.fromOctetString(c_obj.paymentFeeUnit);
  }
}

class PayUnit {
  late String payUnit;
  PayUnit.fromOctetString(C.OCTET_STRING_t string){
    
    if (string.buf == nullptr) {
      payUnit = "";  // or throw exception
      return;
    }
    
    if (string.size <= 0) {
      payUnit = "";
      return;
    }
    
    if (string.size > 1024) {  // Sanity check - adjust limit as needed
      payUnit = "";
      return;
    }
    final Uint8List byteList = string.buf.asTypedList(string.size);
    payUnit = String.fromCharCodes(byteList);
  }
}