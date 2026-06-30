import 'dart:ffi';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/common/d_day.dart';
import 'package:asn1_plugin/j2735/2024/common/d_hour.dart';
import 'package:asn1_plugin/j2735/2024/common/d_minute.dart';
import 'package:asn1_plugin/j2735/2024/common/d_month.dart';
import 'package:asn1_plugin/j2735/2024/common/d_offset.dart';
import 'package:asn1_plugin/j2735/2024/common/d_second.dart';
import 'package:asn1_plugin/j2735/2024/common/d_year.dart';
import 'package:ffi/ffi.dart';

class DDateTime {
  DYear? year;
  DMonth? month;
  DDay? day;
  DHour? hour;
  DMinute? minute;
  DSecond? second;
  DOffset? offset;

  DDateTime.fromDateTime(DateTime dateTime) {
    year = DYear(dateTime.year);
    month = DMonth(dateTime.month);
    day = DDay(dateTime.day);
    hour = DHour(dateTime.hour);
    minute = DMinute(dateTime.minute);
    second = DSecond(dateTime.second * 1000 + dateTime.millisecond);
    // Offset in minutes from UTC
    offset = DOffset(dateTime.timeZoneOffset.inMinutes);
  }

  DDateTime.fromC(C.DDateTime c_dDateTime) {
    if (c_dDateTime.year.address != 0) {
      year = DYear(c_dDateTime.year.value);
    }

    if (c_dDateTime.month.address != 0) {
      month = DMonth(c_dDateTime.month.value);
    }

    if (c_dDateTime.day.address != 0) {
      day = DDay(c_dDateTime.day.value);
    }

    if (c_dDateTime.hour.address != 0) {
      hour = DHour(c_dDateTime.hour.value);
    }

    if (c_dDateTime.minute.address != 0) {
      minute = DMinute(c_dDateTime.minute.value);
    }

    if (c_dDateTime.second.address != 0) {
      second = DSecond(c_dDateTime.second.value);
    }

    if (c_dDateTime.offset.address != 0) {
      offset = DOffset(c_dDateTime.offset.value);
    }
  }

  void toC(Pointer<C.DDateTime> pointer) {
    final c_dDateTime = pointer.ref;
    
    pointer.cast<Uint8>().asTypedList(sizeOf<C.DDateTime>()).fillRange(0, sizeOf<C.DDateTime>(), 0);
    
    if (year != null) {
      final yearPtr = calloc<Int32>();
      yearPtr.value = year!.dYear;
      c_dDateTime.year = yearPtr as Pointer<C.DYear_t>;
    } else {
      c_dDateTime.year = nullptr;
    }
    
    if (month != null) {
      final monthPtr = calloc<Int32>();
      monthPtr.value = month!.dMonth;
      c_dDateTime.month = monthPtr as Pointer<C.DMonth_t>;
    } else {
      c_dDateTime.month = nullptr;
    }
    
    if (day != null) {
      final dayPtr = calloc<Int32>();
      dayPtr.value = day!.dDay;
      c_dDateTime.day = dayPtr as Pointer<C.DDay_t>;
    } else {
      c_dDateTime.day = nullptr;
    }
    
    if (hour != null) {
      final hourPtr = calloc<Int32>();
      hourPtr.value = hour!.dHour;
      c_dDateTime.hour = hourPtr as Pointer<C.DHour_t>;
    } else {
      c_dDateTime.hour = nullptr;
    }
    
    if (minute != null) {
      final minutePtr = calloc<Int32>();
      minutePtr.value = minute!.dMinute;
      c_dDateTime.minute = minutePtr as Pointer<C.DMinute_t>;
    } else {
      c_dDateTime.minute = nullptr;
    }
    
    if (second != null) {
      final secondPtr = calloc<Int32>();
      secondPtr.value = second!.dSecond;
      c_dDateTime.second = secondPtr as Pointer<C.DSecond_t>;
    } else {
      c_dDateTime.second = nullptr;
    }
    
    if (offset != null) {
      final offsetPtr = calloc<Int32>();
      offsetPtr.value = offset!.dOffset;
      c_dDateTime.offset = offsetPtr as Pointer<C.DOffset_t>;
    } else {
      c_dDateTime.offset = nullptr;
    }
  }

  void free(Pointer<C.DDateTime> pointer) {
    final c_dDateTime = pointer.ref;

    if (c_dDateTime.year != nullptr) {
      calloc.free(c_dDateTime.year);
      c_dDateTime.year = nullptr;
    }

    if (c_dDateTime.month != nullptr) {
      calloc.free(c_dDateTime.month);
      c_dDateTime.month = nullptr;
    }

    if (c_dDateTime.day != nullptr) {
      calloc.free(c_dDateTime.day);
      c_dDateTime.day = nullptr;
    }

    if (c_dDateTime.hour != nullptr) {
      calloc.free(c_dDateTime.hour);
      c_dDateTime.hour = nullptr;
    }

    if (c_dDateTime.minute != nullptr) {
      calloc.free(c_dDateTime.minute);
      c_dDateTime.minute = nullptr;
    }

    if (c_dDateTime.second != nullptr) {
      calloc.free(c_dDateTime.second);
      c_dDateTime.second = nullptr;
    }

    if (c_dDateTime.offset != nullptr) {
      calloc.free(c_dDateTime.offset);
      c_dDateTime.offset = nullptr;
    }

    calloc.free(pointer);
  }

  DateTime getAsDateTime() {
    int second = ((this.second?.dSecond ?? 0) / 1000).toInt();
    int millisecond = (this.second?.dSecond ?? 0) % 1000;

    return DateTime(this.year?.dYear ?? 0, this.month?.dMonth ?? 0, this.day?.dDay ?? 0, this.hour?.dHour ?? 0,
        this.minute?.dMinute ?? 0, second, millisecond);
  }
}
