import 'package:asn1_plugin/j2735/2024/common/basic_vehicle_class.dart';
import 'package:asn1_plugin/j2735/2024/common/lightbar_in_use.dart';
import 'package:asn1_plugin/j2735/2024/common/siren_in_use.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/received_messages/receieved_msg.dart';
import 'package:latlong2/latlong.dart';

class ReceivedBsm extends ReceivedMsg {
  late VehicleClass vehicleClass;
  SirenInUse sirens = SirenInUse.unavailable;
  LightbarInUse lights = LightbarInUse.unavailable;
  ReceivedBsm(String id, DateTime objectTime, LatLng refPos, VehicleClass vehicleClass, this.lights, this.sirens)
      : super() {
    this.id = id;
    this.dateTime = objectTime;
    this.position = refPos;
    this.type = MsgType.BSM;
    this.vehicleClass = vehicleClass;
  }

  @override
  String getKey() {
    return "${vehicleClass.name}_$id";
  }
}
