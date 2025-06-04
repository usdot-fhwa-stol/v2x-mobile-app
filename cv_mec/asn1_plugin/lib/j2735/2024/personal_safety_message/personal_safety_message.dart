import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/acceleration_set_4_way.dart';
import 'package:asn1_plugin/j2735/2024/common/d_second.dart';
import 'package:asn1_plugin/j2735/2024/common/heading.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/path_history.dart';
import 'package:asn1_plugin/j2735/2024/common/path_prediction.dart';
import 'package:asn1_plugin/j2735/2024/common/position_3d.dart';
import 'package:asn1_plugin/j2735/2024/common/positional_accuracy.dart';
import 'package:asn1_plugin/j2735/2024/common/temporary_id.dart';
import 'package:asn1_plugin/j2735/2024/common/velocity.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/animal_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/attachment.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/attachment_radius.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/number_of_participants_in_cluster.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_assistive.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_cluster_radius.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_crossing_in_progress.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_crossing_request.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_usage_state.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/propelled_information.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_and_road_worker_activity.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_directing_traffic_sub_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_event_responder_worker_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/user_size_and_behavior.dart';

class PersonalSafetyMessage {
  late PersonalDeviceUserType basicType;
  late DSecond secMark;
  late MsgCount msgCnt;
  late TemporaryID id;
  late Position3D position;
  late PositionalAccuracy accuracy;
  late Velocity speed;
  late Heading heading;
  AccelerationSet4Way? accelSet;
  PathHistory? pathHistory;
  PathPrediction? pathPrediction;
  PropelledInformation? propulsion;
  PersonalDeviceUsageState? useState;
  PersonalCrossingRequest? crossRequest;
  PersonalCrossingInProgress? crossState;
  NumberOfParticipantsInCluster? clusterSize;
  PersonalClusterRadius? clusterRadius;
  PublicSafetyEventResponderWorkerType? eventResponderType;
  PublicSafetyAndRoadWorkerActivity? activityType;
  PublicSafetyDirectingTrafficSubType? activitySubType;
  PersonalAssistive? assistType;
  UserSizeAndBehavior? sizing;
  Attachment? attachment;
  AttachmentRadius? attachmentRadius;
  AnimalType? animalType;

  PersonalSafetyMessage.fromC(C.PersonalSafetyMessage c_personalSafetyMessage) {
    basicType = PersonalDeviceUserType.values[c_personalSafetyMessage.basicType];
    secMark = DSecond(c_personalSafetyMessage.secMark);
    id = TemporaryID.fromOctetString(c_personalSafetyMessage.id);
    position = Position3D.fromC(c_personalSafetyMessage.position);
    accuracy = PositionalAccuracy.fromC(c_personalSafetyMessage.accuracy);
    speed = Velocity(c_personalSafetyMessage.speed);
    heading = Heading(c_personalSafetyMessage.heading);

    if (c_personalSafetyMessage.accelSet.address != 0) {
      accelSet = AccelerationSet4Way.fromC(c_personalSafetyMessage.accelSet.ref);
    }

    if (c_personalSafetyMessage.pathHistory.address != 0) {
      pathHistory = PathHistory.fromC(c_personalSafetyMessage.pathHistory.ref);
    }

    if (c_personalSafetyMessage.pathPrediction.address != 0) {
      pathPrediction = PathPrediction.fromC(c_personalSafetyMessage.pathPrediction.ref);
    }

    if (c_personalSafetyMessage.propulsion.address != 0) {
      propulsion = PropelledInformation.fromC(c_personalSafetyMessage.propulsion.ref);
    }

    if (c_personalSafetyMessage.useState.address != 0) {
      useState = PersonalDeviceUsageState.fromBitString(c_personalSafetyMessage.useState.ref);
    }

    if (c_personalSafetyMessage.useState.address != 0) {
      crossRequest = PersonalCrossingRequest(c_personalSafetyMessage.crossRequest.value);
    }

    if (c_personalSafetyMessage.crossState.address != 0) {
      crossState = PersonalCrossingInProgress(c_personalSafetyMessage.crossState.value);
    }

    if (c_personalSafetyMessage.clusterSize.address != 0) {
      clusterSize = NumberOfParticipantsInCluster.values[c_personalSafetyMessage.clusterSize.value];
    }

    if (c_personalSafetyMessage.clusterRadius.address != 0) {
      clusterRadius = PersonalClusterRadius(c_personalSafetyMessage.clusterRadius.value);
    }

    if (c_personalSafetyMessage.eventResponderType.address != 0) {
      eventResponderType =
          PublicSafetyEventResponderWorkerType.values[c_personalSafetyMessage.eventResponderType.value];
    }

    if (c_personalSafetyMessage.activityType.address != 0) {
      activityType = PublicSafetyAndRoadWorkerActivity.fromBitString(c_personalSafetyMessage.activityType.ref);
    }

    if (c_personalSafetyMessage.activitySubType.address != 0) {
      activitySubType = PublicSafetyDirectingTrafficSubType.fromBitString(c_personalSafetyMessage.activitySubType.ref);
    }

    if (c_personalSafetyMessage.assistType.address != 0) {
      assistType = PersonalAssistive.fromBitString(c_personalSafetyMessage.assistType.ref);
    }

    if (c_personalSafetyMessage.sizing.address != 0) {
      sizing = UserSizeAndBehavior.fromBitString(c_personalSafetyMessage.sizing.ref);
    }

    if (c_personalSafetyMessage.attachment.address != 0) {
      attachment = Attachment.values[c_personalSafetyMessage.attachment.value];
    }

    if (c_personalSafetyMessage.attachmentRadius.address != 0) {
      attachmentRadius = AttachmentRadius(c_personalSafetyMessage.attachmentRadius.value);
    }

    if (c_personalSafetyMessage.animalType.address != 0) {
      animalType = AnimalType.values[c_personalSafetyMessage.animalType.value];
    }
  }
}
