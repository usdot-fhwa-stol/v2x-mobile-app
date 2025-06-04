import 'dart:async';

import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/itis_code.dart';
import 'package:cv_mec/pages/settings_page.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class VehicleNotificationManager {
  static const platform = MethodChannel('com.neaera.cv_mec/vehicle-notification');

  static SettingsController settingsController = Get.find<SettingsController>();

  static Future<String> _convertImageProviderToBase64(ImageProvider imageProvider) async {
    // Load the image
    final Completer<ui.Image> completer = Completer();
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception, stackTrace);
      },
    );
    stream.addListener(listener);
    final ui.Image image = await completer.future;
    stream.removeListener(listener);

    // Convert the image to bytes
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer.asUint8List();

    // Encode the bytes to a base64 string
    final String base64Image = base64Encode(imageBytes);

    return base64Image;
  }

  static Future<void> _sendNotificationCommand(int id, String message, String? imageB64) async {
    if (!settingsController.notificationsEnabled.value) {
      return;
    }
    print("Sending notification: $message");
    platform.invokeMethod<int>('notify', <String, dynamic>{
      'id': id,
      'description': message,
      'image_b64': imageB64,
    });
  }

  static Future<void> notifyVehicleFromItisCode(ItisCode code) async {
    if (code.image != null) {
      String imageB64String = await _convertImageProviderToBase64(code.image!);
      int id = DateTime.now().millisecondsSinceEpoch;
      _sendNotificationCommand(id, code.description, imageB64String);
    }
  }

  static Future<void> notifyVehicleFromDescriptionImage(String description, ImageProvider image) async {
    String imageB64String = await _convertImageProviderToBase64(image);
    int id = DateTime.now().millisecondsSinceEpoch;
    _sendNotificationCommand(id, description, imageB64String);
  }

  static Future<void> notifyVehicleFromMessageAndImage(String message, ImageProvider<Object> image) async {
    String imageB64String = await _convertImageProviderToBase64(image);
    int id = DateTime.now().millisecondsSinceEpoch;
    _sendNotificationCommand(id, message, imageB64String);
  }

  static Future<void> notifyVehicleFromMessage(String message) async {
    int id = DateTime.now().millisecondsSinceEpoch;
    _sendNotificationCommand(id, message, null);
  }

  static void requestPermissions() async {
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }
}
