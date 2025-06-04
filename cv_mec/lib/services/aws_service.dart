import 'dart:io';
import 'package:archive/archive.dart';
import 'package:aws3_bucket/aws3_bucket.dart';
import 'package:aws3_bucket/aws_region.dart';
import 'package:aws3_bucket/iam_crediental.dart';
import 'package:aws3_bucket/image_data.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/pages/settings_page.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class S3Service extends GetxService {
  SettingsController settingsController = Get.find<SettingsController>();

  Future<bool> uploadFile(String filePath, String directory) async {
    if (settingsController.s3BucketName.value.isNotEmpty) {
      File currentFile = File(filePath);

      String destinationPath = "${path.dirname(filePath)}/upload/${path.basename(filePath)}.gz";

      String destinationDirPath = Directory(destinationPath).parent.path;
      Directory destinationDir = Directory(destinationDirPath);

      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
        print('Upload Created destination directory: $destinationDirPath');
      }

      if (await currentFile.exists()) {
        // Copy the file to the destination
        File copiedFile = await compressFile(currentFile, destinationPath);

        String? result;
        IAMCrediental iamCrediental = IAMCrediental();
        iamCrediental.secretKey = settingsController.s3AccessKey.value;
        iamCrediental.secretId = settingsController.s3SecretKey.value;
        ImageData imageData = ImageData(path.basename(copiedFile.path), copiedFile.path,
            imageUploadFolder: "${settingsController.s3DestDir.value}/$directory");

        result = await Aws3Bucket.upload(settingsController.s3BucketName.value!, AwsRegion.US_EAST_1,
            AwsRegion.AP_NORTHEAST_1, imageData, iamCrediental);

        print("File UPload $result");

        return true;

        // _upload(File(path.dirname(filePath) + "/registration.json"));
      } else {
        print('Upload Source file does not exist!');
      }
    }
    return false;
  }

  Future<File> compressFile(File file, String outputPath) async {
    try {
      // Read the original file as bytes
      final inputBytes = await file.readAsBytes();

      // Compress the file using GZIP
      final compressedBytes = GZipEncoder().encode(inputBytes);

      // Write the compressed bytes to a new file
      final compressedFile = File(outputPath);
      await compressedFile.writeAsBytes(compressedBytes!);

      return compressedFile;
    } catch (e) {
      print('Error compressing file: $e');
      rethrow;
    }
  }
}
