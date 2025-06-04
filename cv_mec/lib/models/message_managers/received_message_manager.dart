import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/object_type.dart';
import 'package:cv_mec/models/itis_code.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/received_messages/receieved_msg.dart';
import 'package:cv_mec/models/received_messages/received_psm.dart';
import 'package:cv_mec/models/received_messages/received_sdsm.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ReceivedMessageManager {
  Map<String, ReceivedMsg> receivedMsgs = {};
  Map<String, bool> shown = {};
  final GeometryService _geometryService = Get.find<GeometryService>();
  final String imageDirectory = "assets/images/ITIS";

  final double fov = 90;
  final double projectionDistanceMeters = 100;
  final double minimumProjectionWidthMeters = 10;

  ReceivedMessageManager() {}

  addOrUpdate(ReceivedMsg msg) {
    String key = msg.getKey();
    if (receivedMsgs.containsKey(key)) {
      if (receivedMsgs[key]!.dateTime.isBefore(msg.dateTime)) {
        receivedMsgs[key] = msg;
      }
    } else {
      receivedMsgs[key] = msg;
    }
  }

  List<ReceivedMsg> getNewReceivedMessages(LatLng position, double heading) {
    List<ReceivedMsg> newMsgs = [];
    Polygon polygon = _geometryService.getConicSectionProjection(
        position, heading, minimumProjectionWidthMeters, fov, projectionDistanceMeters);
    for (MapEntry<String, ReceivedMsg> msg in receivedMsgs.entries) {
      if (_geometryService.isPointInPolygon(polygon, msg.value.position.longitude, msg.value.position.latitude)) {
        if (!shown.containsKey(msg.key)) {
          // Add key only if the message has not been shown before
          newMsgs.add(msg.value);
          shown[msg.key] = true;
        }
      } else {
        // Clean out Keys if Messages are no longer in the zone. Allowing it to alert again
        if (shown.containsKey(msg.key)) {
          shown.remove(msg.key);
        }
      }
    }
    return newMsgs;
  }

  List<ReceivedMsg> getActiveMessages(LatLng position, double heading) {
    List<ReceivedMsg> activeMessages = [];
    Polygon polygon = _geometryService.getConicSectionProjection(
        position, heading, minimumProjectionWidthMeters, fov, projectionDistanceMeters);
    for (MapEntry<String, ReceivedMsg> msg in receivedMsgs.entries) {
      if (_geometryService.isPointInPolygon(polygon, msg.value.position.longitude, msg.value.position.latitude)) {
        activeMessages.add(msg.value);
      }
    }
    return activeMessages;
  }

  List<ItisCode> convertToItisCodes(List<ReceivedMsg> messages) {
    List<ItisCode> codes = [];
    for (ReceivedMsg msg in messages) {
      if (msg.type == MsgType.SDSM) {
        ItisCode? code = getITISForSDSM(msg as ReceivedSdsm);
        if (code != null) {
          codes.add(code);
        }
      } else if (msg.type == MsgType.PSM) {
        ItisCode? code = getITISForPSM(msg as ReceivedPsm);
        if (code != null) {
          codes.add(code);
        }
      } else if (msg.type == MsgType.BSM) {
        // No alerts currently supported for BSM messages.
      }
    }
    return codes;
  }

  ItisCode? getITISForSDSM(ReceivedSdsm sdsm) {
    if (sdsm.objectType == ObjectType.animal) {
      return ItisCode.withImage(43, "Animal Ahead", [], AssetImage("$imageDirectory/dog.png"));
    } else if (sdsm.objectType == ObjectType.vru) {
      return ItisCode.withImage(43, "Pedestrian Ahead", [], AssetImage("$imageDirectory/pedcrossing.png"));
    } else if (sdsm.objectType == ObjectType.unknown) {
      return ItisCode.withImage(43, "Unknown Object Ahead", [], AssetImage("$imageDirectory/pedcrossing.png"));
    }
    return null;
  }

  ItisCode? getITISForPSM(ReceivedPsm psm) {
    if (psm.deviceType == PersonalDeviceUserType.APEDESTRIAN) {
      return ItisCode.withImage(43, "Pedestrian Ahead", [], AssetImage("$imageDirectory/pedcrossing.png"));
    } else if (psm.deviceType == PersonalDeviceUserType.APEDALCYCLIST) {
      return ItisCode.withImage(43, "Cyclist Ahead", [], AssetImage("$imageDirectory/bicycle.png"));
    } else if (psm.deviceType == PersonalDeviceUserType.ANANIMAL) {
      return ItisCode.withImage(43, "Animal Ahead", [], AssetImage("$imageDirectory/dog.png"));
    } else if (psm.deviceType == PersonalDeviceUserType.APUBLICSAFETYWORKER) {
      return ItisCode.withImage(43, "Public Safety Worker Ahead", [], AssetImage("$imageDirectory/pedcrossing.png"));
    }
    return null;
  }
}
