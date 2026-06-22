import 'package:cv_mec/services/logging_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img_lib;

class ItisImageResolver{
  LoggingService loggingService = Get.find<LoggingService>();
  
  Future<ImageProvider> getImage(String imageName) async {
    throw UnimplementedError("This is an abstract class - Make sure to only call this method on subclasses");
  }

  Future<img_lib.Image?> getDecodedImage(String imageName) async{
    throw UnimplementedError("This is an abstract class - Make sure to only call this method on subclasses");
  }

  Future<ImageProvider> getMissing() async {
    return const AssetImage("assets/images/tims/missing.png");
  }
}