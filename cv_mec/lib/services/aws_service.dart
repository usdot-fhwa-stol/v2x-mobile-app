import 'dart:io';
import 'package:archive/archive.dart';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class S3Service extends GetxService {
  final SettingsController settings = Get.find<SettingsController>();
  final timingService = Get.find<Timing>();
  LoggingService loggingService = Get.find<LoggingService>();

  Future<bool> uploadFile(String filePath, String directory) async {
    final bucket = settings.s3BucketName.value;
    if (bucket.isEmpty) return false;

    final original = File(filePath);
    if (!await original.exists()) return false;

    DateTime now = timingService.getTime();

    final gzName = "${removeExtension(path.basename(filePath))}_${now.millisecondsSinceEpoch}.${getExtension(filePath)}.gz";



    // Compress
    final uploadDir = path.join(path.dirname(filePath), 'upload');
    await Directory(uploadDir).create(recursive: true);
    final gzPath = path.join(uploadDir, gzName);
    final bytes = await original.readAsBytes();
    final gzBytes = GZipEncoder().encode(bytes)!;
    final gzFile = await File(gzPath).writeAsBytes(gzBytes);

    try {
      final String result = await AwsS3.uploadFile(
        accessKey:   settings.s3AccessKey.value,
        secretKey:   settings.s3SecretKey.value,
        bucket:      settings.s3BucketName.value,
        region:      settings.s3Region.value,
        file:        gzFile,
        destDir:     '${settings.s3DestDir.value}/$directory',
        filename:    path.basename(gzFile.path),
        contentType: 'application/gzip',
      );

      loggingService.addToAppLog("File Uploaded with Result: $result");

      final code = int.tryParse(result);

      if (code != null && code >= 200 && code < 300) {
        loggingService.addToAppLog("File Uploaded Successfully: ${gzFile.path}");
        return true;
      } else {
        loggingService.showError("Failed to upload file. Result: $result");
        return false;
      }
    } catch (e) {
      loggingService.showError("Failed to upload file: $e");
      return false;
    }
  }

  String removeExtension(String filename) {
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex != -1) {
      return filename.substring(0, dotIndex);
    }
    return filename; // No extension found
  }

  String getExtension(String filename) {
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex != -1) {
      return filename.substring(dotIndex+1);
    }
    return filename; // No extension found
  }
}
