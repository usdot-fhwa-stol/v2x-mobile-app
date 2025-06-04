import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:cv_mec/models/geometry_direction.dart';

class DataFrameGeometry {
  late List<GeometryDirection> geometry;
  late TravelerDataFrame frame;
  bool active = false;
  bool shown = false;

  DataFrameGeometry(this.frame, this.geometry);
}
