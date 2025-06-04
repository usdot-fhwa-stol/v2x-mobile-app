// import 'package:asn1_plugin/generated_bindings.dart' as C;
// import 'package:asn1_plugin/j2735/2024/common/d_day.dart';
// import 'package:asn1_plugin/j2735/2024/common/d_hour.dart';
// import 'package:asn1_plugin/j2735/2024/common/d_minute.dart';
// import 'package:asn1_plugin/j2735/2024/common/d_month.dart';
// import 'package:asn1_plugin/j2735/2024/common/d_second.dart';
// import 'package:asn1_plugin/j2735/2024/common/d_year.dart';
// import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
// import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/detected_object_data.dart';
// import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/sensor_data_sharing_message.dart';
// import 'package:cv_mec/models/msg_types.dart';
// import 'package:cv_mec/models/receieved_msg.dart';
// import 'package:cv_mec/services/asn_service.dart';
// import 'package:cv_mec/services/geometry_service.dart';
// import 'package:dart_jts/dart_jts.dart';
// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';

// class SdsmManager {
//   Map<String, SensorDataSharingMessage> sdsms = <String, SensorDataSharingMessage>{};
//   GeometryService geometryService = Get.find<GeometryService>();

//   void addOrUpdate(SensorDataSharingMessage sdsm, String asn1) {
//     String sdsmID = ASNService.bytesToHex(sdsm.sourceID.temporaryID);

//     if (sdsms.containsKey(sdsmID)) {
//       int msgCount = sdsms[sdsmID]!.msgCnt.msgCount;
//       if (msgCount < sdsm.msgCnt.msgCount) {
//         sdsms[sdsmID] = sdsm;
//       } else if (msgCount > 120 && sdsm.msgCnt.msgCount < 5) {
//         // handle the rollover case.
//         sdsms[sdsmID] = sdsm;
//       }
//     } else {
//       sdsms[sdsmID] = sdsm;
//     }
//   }

//   void addOrUpdateWithTime(SensorDataSharingMessage sdsm, String asn1, DateTime refTime) {
//     sdsm.sDSMTimeStamp.year ??= DYear(refTime.year);
//     sdsm.sDSMTimeStamp.month ??= DMonth(refTime.month);
//     sdsm.sDSMTimeStamp.day ??= DDay(refTime.day);
//     sdsm.sDSMTimeStamp.hour ??= DHour(refTime.hour);
//     sdsm.sDSMTimeStamp.minute ??= DMinute(refTime.minute);
//     sdsm.sDSMTimeStamp.second ??= DSecond(refTime.second);
//   }

//   void getActiveObjects(DateTime appTime) {
//     List<String> deleteKeys = [];
//     List<ReceivedMsg> receivedMsgs = [];
//     for (MapEntry<String, SensorDataSharingMessage> entry in sdsms.entries) {
//       bool shouldDelete = true;
//       DateTime refTime = entry.value.sDSMTimeStamp.getAsDateTime();
//       LatLng refPos =
//           LatLng(entry.value.refPos.lat.getDecimalLatitude(), entry.value.refPos.long.getDecimalLongitude());

//       for (DetectedObjectData object in entry.value.objects.objects) {
//         String id = "${entry.key}_${object.detObjCommon.objectID.objectID}";
//         DateTime objectTime =
//             refTime.add(Duration(milliseconds: object.detObjCommon.measurementTime.mesurementTimeOffset));

//         if (objectTime.isAfter(appTime.subtract(Duration(seconds: 1))) &&
//             objectTime.isBefore(appTime.add(Duration(seconds: 1)))) {
//           geometryService.shiftLatLng(refPos, object.detObjCommon.pos.offsetX.getDistanceInMeters(),
//               object.detObjCommon.pos.offsetY.getDistanceInMeters());

//           receivedMsgs.add(ReceivedMsg(id, objectTime, refPos, MsgType.SDSM, object.detObjCommon.objType.name));
//           shouldDelete = false;
//         }
//       }
//       if (shouldDelete) {
//         deleteKeys.add(entry.key);
//       }
//     }
//     for (String key in deleteKeys) {
//       sdsms.remove(key);
//     }
//   }
// }
