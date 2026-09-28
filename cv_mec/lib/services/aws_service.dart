import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show RootIsolateToken;
import 'package:archive/archive.dart';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class S3Service extends GetxService {
  final SettingsController settings = Get.find<SettingsController>();
  final timingService = Get.find<Timing>();
  LoggingService loggingService = Get.find<LoggingService>();
  final RootIsolateToken? _rootIsolateToken = RootIsolateToken.instance;

  Future<bool> uploadFile(String filePath, String directory) async {
    final bucket = settings.s3BucketName.value;
    if (bucket.isEmpty) return false;

    final original = File(filePath);
    if (!await original.exists()) return false;

    final RootIsolateToken? token = _rootIsolateToken;
    if (token == null) {
      loggingService.showError("Unable to upload file in isolate: RootIsolateToken was null.");
      return false;
    }

    DateTime now = timingService.getTime();

    final gzName = "${removeExtension(path.basename(filePath))}_${now.millisecondsSinceEpoch}.${getExtension(filePath)}.gz";

    final uploadDir = path.join(path.dirname(filePath), 'upload');
    final gzPath = path.join(uploadDir, gzName);

    final isolateArgs = <String, dynamic>{
      'token': token,
      'filePath': filePath,
      'directory': directory,
      'uploadDir': uploadDir,
      'gzPath': gzPath,
      'accessKey': settings.s3AccessKey.value,
      'secretKey': settings.s3SecretKey.value,
      'bucket': settings.s3BucketName.value,
      'region': settings.s3Region.value,
      'destRoot': settings.s3DestDir.value,
    };

    try {
      final Map<String, dynamic> result = await Isolate.run(
        () => _uploadFileInIsolate(isolateArgs),
      );

      final bool success = result['success'] as bool? ?? false;
      final String message = result['message'] as String? ?? 'Unknown upload result';
      final String gzFilePath = result['gzPath'] as String? ?? gzPath;

      loggingService.addToAppLog("File Uploaded with Result: $message");
      if (success) {
        loggingService.addToAppLog("File Uploaded Successfully: $gzFilePath");
        return true;
      }

      loggingService.showError("Failed to upload file. Result: $message");
      return false;
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

Future<Map<String, dynamic>> _uploadFileInIsolate(Map<String, dynamic> args) async {
  final RootIsolateToken token = args['token'] as RootIsolateToken;
  final String filePath = args['filePath'] as String;
  final String directory = args['directory'] as String;
  final String uploadDir = args['uploadDir'] as String;
  final String gzPath = args['gzPath'] as String;
  final String accessKey = args['accessKey'] as String;
  final String secretKey = args['secretKey'] as String;
  final String bucket = args['bucket'] as String;
  final String region = args['region'] as String;
  final String destRoot = args['destRoot'] as String;

  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  final sourceFile = File(filePath);
  if (!await sourceFile.exists()) {
    return <String, dynamic>{
      'success': false,
      'message': 'Source file did not exist at upload time.',
    };
  }

  await Directory(uploadDir).create(recursive: true);
  final sourceBytes = await sourceFile.readAsBytes();
  final compressedBytes = GZipEncoder().encode(sourceBytes);
  final gzFile = await File(gzPath).writeAsBytes(compressedBytes);

  final String uploadResult = await AwsS3.uploadFile(
    accessKey: accessKey,
    secretKey: secretKey,
    bucket: bucket,
    region: region,
    file: gzFile,
    destDir: '$destRoot/$directory',
    filename: path.basename(gzFile.path),
    contentType: 'application/gzip',
  );

  final code = int.tryParse(uploadResult);
  final success = code != null && code >= 200 && code < 300;

  return <String, dynamic>{
    'success': success,
    'message': uploadResult,
    'gzPath': gzFile.path,
  };
}
