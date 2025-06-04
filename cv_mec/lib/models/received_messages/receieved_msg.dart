import 'package:cv_mec/models/msg_types.dart';
import 'package:latlong2/latlong.dart';

abstract class ReceivedMsg {
  late String id;
  late DateTime dateTime;
  late LatLng position;
  late MsgType type;

  ReceivedMsg();

  String getKey();
}
