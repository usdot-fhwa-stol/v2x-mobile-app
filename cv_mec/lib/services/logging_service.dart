import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/services/aws_service.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

enum LoggingLevel {
  debug,
  info,
  warning,
  error
}

class LoggingService extends GetxService {
  late Timing timingService;
  late SettingsController settingsController;
  late S3Service awsService;
  final Logger _logger = Logger();
  LoggingLevel loggingLevel = LoggingLevel.info;
  late DataQueue appDataQueue;
  bool initialized = false;

  LoggingService() {
    createAppDataQueue();
  }

  void initialize() {
    settingsController = Get.find<SettingsController>();
    awsService = Get.find<S3Service>();
    timingService = Get.find<Timing>();
    loggingLevel = parseLoggingLevel(settingsController.loggingLevel);
    initialized = true;
    logInfo("Logging Service Initialized. Timestamps before this point use system time. Timestamps after this point use synchronized time from Timing service.");
    logInfo("Logging level set to $loggingLevel.");
    
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

  LoggingLevel parseLoggingLevel(String level) {
    switch (level.toLowerCase()) {
      case 'debug':
        return LoggingLevel.debug;
      case 'warning':
      case 'warn':
        return LoggingLevel.warning;
      case 'error':
        return LoggingLevel.error;
      case 'info':
      default:
        return LoggingLevel.info;
    }
  }

  bool shouldLog(LoggingLevel level) {
    return level.index >= loggingLevel.index;
  }

  void logInfo(String message) {
    if (!shouldLog(LoggingLevel.info)) {
      return;
    }
    _logger.i("INFO ${getLogTime()}: $message");
    appDataQueue.addItem("INFO    ${getLogTime()}: $message\n");
  }

  void logDebug(String message) {
    if (!shouldLog(LoggingLevel.debug)) {
      return;
    }
    _logger.d("DEBUG ${getLogTime()}: $message");
    appDataQueue.addItem("DEBUG   ${getLogTime()}: $message\n");
  }

  void logError(String message) {
    if (!shouldLog(LoggingLevel.error)) {
      return;
    }
    _logger.e("ERROR ${getLogTime()}: $message");
    appDataQueue.addItem("ERROR   ${getLogTime()}: $message\n");
  }

  void logWarning(String message) {
    if (!shouldLog(LoggingLevel.warning)) {
      return;
    }
    _logger.w("WARNING ${getLogTime()}: $message");
    appDataQueue.addItem("WARNING ${getLogTime()}: $message\n");
  }

  @deprecated
  /// Use [logInfo] instead.
  void addToAppLog(String message) {
    logInfo(message);
  }

  @deprecated
  /// Use [logDebug] instead.
  void addToDebugLog(String message) {
    logDebug(message);
  }

  @deprecated
  /// Use [logError] instead.
  void showError(String message) {
    logError(message);
  }

  @deprecated
  /// Use [logWarning] instead.
  void showWarning(String message) {
    logWarning(message);
  }

  Future<bool> rotateAndUploadAppLog(String deviceID) async {
    logInfo(
        "Rotating App Log File.");

    String appLogPath = appDataQueue.filePath;

    // Assigns new Data Queue objects for the app log. Rotate before upload to ensure no data is lost
    createAppDataQueue();

    logInfo(
        "App Log Rotation Complete.");

    if (settingsController.deviceID.value.isNotEmpty) {
      return await awsService.uploadFile(
          appLogPath, "app_logs/${settingsController.deviceID.value}");
    } else {
      return await awsService.uploadFile(appLogPath, "app_logs/$deviceID");
    }
  }
}
