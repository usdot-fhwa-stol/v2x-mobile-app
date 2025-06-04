import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'dart:ffi';
import 'package:asn1_plugin/j2735/2024/spat/time_mark.dart';

class TimeChangeDetails {
  TimeMark? startTime;
  late TimeMark minEndTime;
  TimeMark? maxEndTime;
  TimeMark? likelyTime;
  TimeMark? confidence;
  TimeMark? nextTime;

  TimeChangeDetails.fromC(C.TimeChangeDetails c_timeChangeDetails) {
    if (c_timeChangeDetails.startTime.address != 0) {
      startTime = TimeMark(c_timeChangeDetails.startTime.value);
    }

    if (c_timeChangeDetails.minEndTime != 0) {
      minEndTime = TimeMark(c_timeChangeDetails.minEndTime);
    }

    if (c_timeChangeDetails.maxEndTime.address != 0) {
      maxEndTime = TimeMark(c_timeChangeDetails.maxEndTime.value);
    }

    if (c_timeChangeDetails.likelyTime.address != 0) {
      likelyTime = TimeMark(c_timeChangeDetails.likelyTime.value);
    }

    if (c_timeChangeDetails.confidence.address != 0) {
      confidence = TimeMark(c_timeChangeDetails.confidence.value);
    }

    if (c_timeChangeDetails.nextTime.address != 0) {
      nextTime = TimeMark(c_timeChangeDetails.nextTime.value);
    }
  }
}
