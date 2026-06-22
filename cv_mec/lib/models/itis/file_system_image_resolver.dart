import 'package:cv_mec/models/archive_directory.dart';
import 'package:cv_mec/models/itis/itis_image_resolver.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;
import 'package:get/get.dart';

class FileSystemImageResolver extends ItisImageResolver{

  FileService fileService = Get.find<FileService>();
  LoggingService loggingService = Get.find<LoggingService>();

  @override
  Future<ImageProvider> getImage(String imageName) async {
     try{
      img_lib.Image? image = await getDecodedImage(imageName);
      if(image != null){
        return MemoryImage(img_lib.encodePng(image));
      }else{
        loggingService.showError("Unable to Load Image from File System for Name $imageName. Image is null.");
        return getMissing();
      }
      
    } on Exception catch(e){
      loggingService.showError("Unable to Load Image from File System for Name $imageName");
      return getMissing();
    }
  }

  @override
  Future<img_lib.Image?> getDecodedImage(String imageName) async{
    if(await fileService.checkIfFileExists("$imageName", directory: ArchiveDirectory.APPLICATION_DOCUMENTS) == false){
        loggingService.showError("Dynamic Image File does not exist $imageName");
        return null;
    }
    img_lib.Image? baseSizeImage = await img_lib.decodePngFile("${await fileService.getDirectory(ArchiveDirectory.APPLICATION_DOCUMENTS)}/$imageName");
    return baseSizeImage;
  }
}