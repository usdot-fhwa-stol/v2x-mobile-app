import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/object_type.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/received_messages/receieved_msg.dart';
import 'package:latlong2/latlong.dart';

class ReceivedSdsm extends ReceivedMsg {
  late ObjectType objectType;
  ReceivedSdsm(String id, DateTime objectTime, LatLng refPos, ObjectType objType) : super() {
    this.id = id;
    this.dateTime = objectTime;
    this.position = refPos;
    this.type = MsgType.SDSM;
    this.objectType = objType;
  }

  @override
  String getKey() {
    return "${objectType.name}_$id";
  }
}
