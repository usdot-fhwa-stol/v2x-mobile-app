import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_event_responder_worker_type.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/received_messages/receieved_msg.dart';
import 'package:latlong2/latlong.dart';

class ReceivedPsm extends ReceivedMsg {
  PersonalDeviceUserType deviceType;
  PublicSafetyEventResponderWorkerType? workerType;

  ReceivedPsm(String id, DateTime objectTime, LatLng refPos, this.deviceType, this.workerType) : super() {
    this.id = id;
    this.dateTime = objectTime;
    this.position = refPos;
    this.type = MsgType.PSM;
  }

  @override
  String getKey() {
    return "${deviceType.name}_$id";
  }
}
