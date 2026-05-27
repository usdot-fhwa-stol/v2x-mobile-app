import 'dart:math';

import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:cv_mec/models/geometry_direction.dart';
import 'package:cv_mec/models/mappable_tim.dart';
import 'package:flutter/material.dart';

class DataFrameGeometry {
  late List<GeometryDirection> geometry;
  late TravelerDataFrame frame;
  late List<MappableTim> mappableTims;
  bool active = false;
  bool shown = false;

  DataFrameGeometry(this.frame, this.geometry) {
    mappableTims = [];
    _loadMappableTims();
  }

  Future<void> _loadMappableTims() async {
    mappableTims = await Future.wait(
      geometry.map((geo) => MappableTim.fromTimGeometry(geo, frame)),
    );
  }
}
