import 'dart:typed_data';

import 'package:cv_mec/models/itis/itis_image_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img_lib;

class RootBundleImageResolver extends ItisImageResolver{

  final String imageDirectory = "assets/images/tims";

  @override
  Future<ImageProvider> getImage(String imageName) async {
    try{
      return AssetImage("$imageDirectory/$imageName");
    }
    catch (e) {
      loggingService.showError("Unable to Load Image from Root Bundle Assets for Name $imageName");
      return getMissing();
    }
  }

  @override
  Future<img_lib.Image?> getDecodedImage(String imageName) async{
    final ByteData assetImageByteData = await rootBundle.load('$imageDirectory/$imageName');
    img_lib.Image? baseSizeImage = img_lib.decodeImage(assetImageByteData.buffer.asUint8List());
    return baseSizeImage;
  }
}