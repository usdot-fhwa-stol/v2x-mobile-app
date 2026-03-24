import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/object_type.dart';
import 'package:cv_mec/models/itis/itis_sequence.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/received_messages/received_msg.dart';
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
  final String imageDirectory = "assets/images/generic";

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

  List<ItisSequence> convertToItisSequence(List<ReceivedMsg> messages) {
    List<ItisSequence> sequences = [];
    for (ReceivedMsg msg in messages) {
      if (msg.type == MsgType.SDSM) {
        ItisSequence? sequence = getITISForSDSM(msg as ReceivedSdsm);
        if (sequence != null) {
          sequences.add(sequence);
        }
      } else if (msg.type == MsgType.PSM) {
        ItisSequence? sequence = getITISForPSM(msg as ReceivedPsm);
        if (sequence != null) {
          sequences.add(sequence);
        }
      } else if (msg.type == MsgType.BSM) {
        // No alerts currently supported for BSM messages.
      }
    }
    return sequences;
  }

  ItisSequence? getITISForSDSM(ReceivedSdsm sdsm) {
    if (sdsm.objectType == ObjectType.animal) {
      return ItisSequence.fromDescription("Animal Ahead", AssetImage("$imageDirectory/dog.png"));
    } else if (sdsm.objectType == ObjectType.vru) {
      return ItisSequence.fromDescription("Pedestrian Ahead", AssetImage("$imageDirectory/pedcrossing.png"));
    } else if (sdsm.objectType == ObjectType.unknown) {
      return ItisSequence.fromDescription("Unknown Object Ahead", AssetImage("$imageDirectory/pedcrossing.png"));
    }
    return null;
  }

  ItisSequence? getITISForPSM(ReceivedPsm psm) {
    if (psm.deviceType == PersonalDeviceUserType.APEDESTRIAN) {
      return ItisSequence.fromDescription("Pedestrian Ahead", AssetImage("$imageDirectory/pedcrossing.png"));
    } else if (psm.deviceType == PersonalDeviceUserType.APEDALCYCLIST) {
      return ItisSequence.fromDescription("Cyclist Ahead", AssetImage("$imageDirectory/bicycle.png"));
    } else if (psm.deviceType == PersonalDeviceUserType.ANANIMAL) {
      return ItisSequence.fromDescription("Animal Ahead", AssetImage("$imageDirectory/dog.png"));
    } else if (psm.deviceType == PersonalDeviceUserType.APUBLICSAFETYWORKER) {
      return ItisSequence.fromDescription("Public Safety Worker Ahead", AssetImage("$imageDirectory/pedcrossing.png"));
    }
    return null;
  }
}
