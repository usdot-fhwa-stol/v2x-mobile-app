import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/acceleration.dart';
import 'vertical_acceleration.dart';
import 'yaw_rate.dart';

class AccelerationSet4Way {
  late Acceleration long;
  late Acceleration lat;
  late VerticalAcceleration vert;
  late YawRate yaw;

  AccelerationSet4Way.fromC(C.AccelerationSet4Way accelerationSet4Way) {
    long = Acceleration(accelerationSet4Way.Long);
    lat = Acceleration(accelerationSet4Way.lat);
    vert = VerticalAcceleration(accelerationSet4Way.vert);
    yaw = YawRate(accelerationSet4Way.yaw);
  }
}
