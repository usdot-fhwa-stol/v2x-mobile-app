import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/full_position_vector.dart';
import 'package:asn1_plugin/j2735/2024/common/gnss_status.dart';
import 'package:asn1_plugin/j2735/2024/common/path_history_point_list.dart';

class PathHistory {
  FullPositionVector? initialPosition;
  GNSSstatus? currGNSStatus;
  late PathHistoryPointList crumbData;

  PathHistory.fromC(C.PathHistory c_pathHistory) {
    if (c_pathHistory.initialPosition.address != 0) {
      initialPosition = FullPositionVector.fromC(c_pathHistory.initialPosition.ref);
    }

    if (c_pathHistory.currGNSSstatus.address != 0) {
      currGNSStatus = GNSSstatus.fromBitString(c_pathHistory.currGNSSstatus.ref);
    }

    crumbData = PathHistoryPointList.fromC(c_pathHistory.crumbData);
  }
}
