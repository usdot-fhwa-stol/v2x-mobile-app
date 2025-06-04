import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/descriptive_name.dart';
import 'package:asn1_plugin/j2735/2024/common/minute_of_the_year.dart';
import 'package:asn1_plugin/j2735/2024/spat/intersection_state_list.dart';

class Spat {
  MinuteOfTheYear? timeStamp;
  DescriptiveName? name;
  late IntersectionStateList intersections;

  Spat.fromC(C.SPAT c_spat) {
    if (c_spat.timeStamp.address != 0) {
      timeStamp = MinuteOfTheYear(c_spat.timeStamp.value);
    }

    if (c_spat.name.address != 0) {
      name = DescriptiveName.fromOctetString(c_spat.name.ref);
    }

    intersections = IntersectionStateList.fromC(c_spat.intersections);
  }
}
