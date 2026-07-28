import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LoggingService extends GetxService {
  late Timing timingService;
  late SettingsController settingsController;
  late S3Service awsService;
  final Logger _logger = Logger();
  late DataQueue appDataQueue;
  bool initialized = false;

  LoggingService() {
    createAppDataQueue();
  }

  void initialize() {
    settingsController = Get.find<SettingsController>();
    awsService = Get.find<S3Service>();
    timingService = Get.find<Timing>();
    initialized = true;
  }

  void createAppDataQueue() {
    late DateTime logTime;
    if (!initialized) {
      logTime = DateTime.now().toUtc();
    } else {
      logTime = timingService.getTime();
    }
    appDataQueue = DataQueue("APP_LOG_${logTime.millisecondsSinceEpoch}.log");
  }

  void addToAppLog(String message) {
    _logger.i("APPLOG: $message");
    appDataQueue.addItem("$message\n");
  }

  void showError(String message) {
    _logger.e("ERROR: $message");
    addToAppLog("ERROR: $message");
  }

  void showWarning(String message) {
    _logger.w("WARNING: $message");
    addToAppLog("WARNING: $message");
  }

  Future<bool> rotateAndUploadAppLog(String deviceID) async {
    addToAppLog(
        "Rotating App Log File. Current Time ${timingService.getTime()}");

    String appLogPath = appDataQueue.filePath;

    // Assigns new Data Queue objects for the app log. Rotate before upload to ensure no data is lost
    createAppDataQueue();

    addToAppLog(
        "App Log Rotation Complete. Current Time ${timingService.getTime()}");

    if (settingsController.deviceID.value.isNotEmpty) {
      return await awsService.uploadFile(
          appLogPath, "app_logs/${settingsController.deviceID.value}");
    } else {
      return await awsService.uploadFile(appLogPath, "app_logs/$deviceID");
    }
  }
}
