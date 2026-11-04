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
    addToAppLog("Logging Service Initialized. Timestamps before this point use system time. Timestamps after this point use synchronized time from Timing service.");
  }

  void createAppDataQueue() {
    appDataQueue = DataQueue("APP_LOG_${getLogTime().millisecondsSinceEpoch}.log");
  }

  DateTime getLogTime(){
    if (!initialized) {
      return DateTime.now().toUtc();
    } else {
      return timingService.getTime();
    }
  }

  void addToAppLog(String message) {
    _logger.i("INFO ${getLogTime()}: $message");
    appDataQueue.addItem("INFO    ${getLogTime()}: $message\n");
  }

  void showError(String message) {
    _logger.e("ERROR ${getLogTime()}: $message");
    appDataQueue.addItem("ERROR   ${getLogTime()}: $message\n");
  }

  void showWarning(String message) {
    _logger.w("WARNING ${getLogTime()}: $message");
    appDataQueue.addItem("WARNING ${getLogTime()}: $message\n");
  }

  Future<bool> rotateAndUploadAppLog(String deviceID) async {
    addToAppLog(
        "Rotating App Log File.");

    String appLogPath = appDataQueue.filePath;

    // Assigns new Data Queue objects for the app log. Rotate before upload to ensure no data is lost
    createAppDataQueue();

    addToAppLog(
        "App Log Rotation Complete.");

    if (settingsController.deviceID.value.isNotEmpty) {
      return await awsService.uploadFile(
          appLogPath, "app_logs/${settingsController.deviceID.value}");
    } else {
      return await awsService.uploadFile(appLogPath, "app_logs/$deviceID");
    }
  }
}
