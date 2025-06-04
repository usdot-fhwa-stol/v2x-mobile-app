import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/transmission_state.dart';
import 'package:asn1_plugin/j2735/2024/common/velocity.dart';

class TransmissionAndSpeed {
  late TransmissionState transmission;
  late Velocity speed;

  TransmissionAndSpeed.fromC(C.TransmissionAndSpeed c_transmissionAndSpeed) {
    transmission = TransmissionState.values[c_transmissionAndSpeed.transmisson];
    speed = Velocity(c_transmissionAndSpeed.speed);
  }
}
