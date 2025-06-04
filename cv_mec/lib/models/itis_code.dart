import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';
import 'package:flutter/material.dart';

class ItisCode {
  late int itis;
  late String description;
  ImageProvider? image;
  late ITIS_CODE_STATUS status;
  late List<Choice_Item> associatedCodes;

  String? name;

  ItisCode(int itis, String description, List<Choice_Item> associatedCodes) {
    this.itis = itis;
    this.description = description;
    this.associatedCodes = associatedCodes;
    status = ITIS_CODE_STATUS.VALID;
    image = null;
  }

  ItisCode.withImage(int itis, String description, List<Choice_Item> associatedCodes, ImageProvider image) {
    this.itis = itis;
    this.description = description;
    this.associatedCodes = associatedCodes;
    this.image = image;
    status = ITIS_CODE_STATUS.VALID;
  }

  ItisCode.error(String error) {
    itis = -1;
    description = error;
    image = null;
    associatedCodes = [];
    status = ITIS_CODE_STATUS.ERROR;
  }

  ItisCode.unknown(int itis) {
    this.itis = -1;
    description = "Received TIM Message with ITIS: $itis";
    image = null;
    associatedCodes = [];
    status = ITIS_CODE_STATUS.UNKNOWN;
  }
}

enum ITIS_CODE_STATUS { UNKNOWN, VALID, ERROR }
