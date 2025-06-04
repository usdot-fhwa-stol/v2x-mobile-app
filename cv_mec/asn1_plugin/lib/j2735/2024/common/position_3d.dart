import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/elevation.dart';
import 'package:asn1_plugin/j2735/2024/common/latitude.dart';
import 'package:asn1_plugin/j2735/2024/common/longitude.dart';
import 'package:asn1_plugin/j2735/2024/common/regional_extension.dart';

class Position3D {
  late Latitude lat;
  late Longitude long;
  Elevation? elevation;
  List<RegionalExtension>? regional;

  Position3D.fromC(C.Position3D position3D) {
    lat = Latitude(position3D.lat);
    long = Longitude(position3D.Long);

    if (position3D.elevation.address != 0) {
      elevation = Elevation(position3D.elevation.value);
    }

    // if(position3D.regional.address != 0){
    //   regional = [];
    //   for(int i=0; i< position3D.regional.ref.list.count; i++){
    //     regional.add(RegionalExtension.fromC(position3D.regional.ref.list.array[i]));
    //   }
    // }
  }
}
