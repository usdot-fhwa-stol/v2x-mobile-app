import 'package:asn1_plugin/j2735/2024/choice/choice_lane_data_attribute.dart';

class MergeDivergeNodeAngle extends Choice_LaneDataAttribute {
  late int mergeDivergeNodeAngle;

  MergeDivergeNodeAngle(this.mergeDivergeNodeAngle);

  MergeDivergeNodeAngle.Unknown() {
    mergeDivergeNodeAngle = 0;
  }
}
