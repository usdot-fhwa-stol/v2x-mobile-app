import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/vehicle_length.dart';
import 'package:asn1_plugin/j2735/2024/common/vehicle_width.dart';

class VehicleSize {
  late VehicleWidth width;
  late VehicleLength length;

  VehicleSize.fromC(C.VehicleSize vehicleSize) {
    width = VehicleWidth(vehicleSize.width);
    length = VehicleLength(vehicleSize.length);
  }
}
