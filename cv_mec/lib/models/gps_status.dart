// GPS Fix values for GPSD TPV Status values

enum GPSStatus {
  unknown,
  normal,
  dgps,
  rtk_fixed,
  rtk_floating,
  dead_reckoning,
  gnss_dr,
  time,
  simulated,
  p_y;



  static GPSStatus fromInt(int value) => switch (value) {
        0 => GPSStatus.unknown,
        1 => GPSStatus.normal,
        2 => GPSStatus.dgps,
        3 => GPSStatus.rtk_fixed,
        4 => GPSStatus.rtk_floating,
        5 => GPSStatus.dead_reckoning,
        6 => GPSStatus.gnss_dr,
        7 => GPSStatus.time,
        8 => GPSStatus.simulated,
        10 => GPSStatus.unknown,
        _ => GPSStatus.unknown,
      };
}