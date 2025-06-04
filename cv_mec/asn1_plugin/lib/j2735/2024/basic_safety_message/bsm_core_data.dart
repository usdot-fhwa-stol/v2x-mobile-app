import 'package:asn1_plugin/j2735/2024/common/acceleration_set_4_way.dart';
import 'package:asn1_plugin/j2735/2024/common/brake_system_status.dart';
import 'package:asn1_plugin/j2735/2024/common/d_second.dart';
import 'package:asn1_plugin/j2735/2024/common/elevation.dart';
import 'package:asn1_plugin/j2735/2024/common/heading.dart';
import 'package:asn1_plugin/j2735/2024/common/latitude.dart';
import 'package:asn1_plugin/j2735/2024/common/longitude.dart';
import 'package:asn1_plugin/j2735/2024/common/msg_count.dart';
import 'package:asn1_plugin/j2735/2024/common/positional_accuracy.dart';
import 'package:asn1_plugin/j2735/2024/common/speed.dart';
import 'package:asn1_plugin/j2735/2024/common/steering_wheel_angle.dart';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/temporary_id.dart';
import 'package:asn1_plugin/j2735/2024/common/transmission_state.dart';
import 'package:asn1_plugin/j2735/2024/common/vehicle_size.dart';

class BSMcoreData {
  late MsgCount msgCnt;
  late TemporaryID id;
  late DSecond secMark;
  late Latitude lat;
  late Longitude long;
  late Elevation elev;
  late PositionalAccuracy accuracy;
  late TransmissionState transmission;
  late Speed speed;
  late Heading heading;
  late SteeringWheelAngle angle;
  late AccelerationSet4Way accelSet;
  late BrakeSystemStatus brakes;
  late VehicleSize size;

  BSMcoreData.fromC(C.BSMcoreData bsmCoreData) {
    msgCnt = MsgCount(bsmCoreData.msgCnt);
    id = TemporaryID.fromOctetString(bsmCoreData.id);
    secMark = DSecond(bsmCoreData.secMark);
    lat = Latitude(bsmCoreData.lat);
    long = Longitude(bsmCoreData.Long);
    elev = Elevation(bsmCoreData.elev);
    accuracy = PositionalAccuracy.fromC(bsmCoreData.accuracy);
    transmission = TransmissionState.values[bsmCoreData.transmission];
    speed = Speed(bsmCoreData.speed);
    heading = Heading(bsmCoreData.heading);
    angle = SteeringWheelAngle(bsmCoreData.angle);
    accelSet = AccelerationSet4Way.fromC(bsmCoreData.accelSet);
    brakes = BrakeSystemStatus.fromC(bsmCoreData.brakes);
    size = VehicleSize.fromC(bsmCoreData.size);
  }

  void toC(C.BSMcoreData bsmCoreData) {
    bsmCoreData.msgCnt = msgCnt.msgCount;
    id.toOctetString(bsmCoreData.id);
    bsmCoreData.secMark = secMark.dSecond;
    bsmCoreData.lat = lat.latitude;
    bsmCoreData.Long = long.longitude;
  }
}
