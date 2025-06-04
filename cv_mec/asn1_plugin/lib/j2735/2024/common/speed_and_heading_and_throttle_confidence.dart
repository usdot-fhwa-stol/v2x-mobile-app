import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/heading_confidence.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_confidence.dart';
import 'package:asn1_plugin/j2735/2024/common/throttle_confidence.dart';

class SpeedandHeadingandThrottleConfidence {
  late HeadingConfidence heading;
  late SpeedConfidence speed;
  late ThrottleConfidence throttle;

  SpeedandHeadingandThrottleConfidence.fromC(
      C.SpeedandHeadingandThrottleConfidence c_speedAndHeadingThrottleConfidence) {
    heading = HeadingConfidence.values[c_speedAndHeadingThrottleConfidence.heading];
    speed = SpeedConfidence.values[c_speedAndHeadingThrottleConfidence.speed];
    throttle = ThrottleConfidence.values[c_speedAndHeadingThrottleConfidence.throttle];
  }
}
