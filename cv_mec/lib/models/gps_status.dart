// GPS Fix values for standard GGA sentences
// Additional information available here: https://mapitgis.com/docs/external-gnss/rtk-and-fix-types/

enum GPSStatus {
  no_fix,
  two_d_fix,
  three_d_fix,
  dgps_fix,
  rtk_fix,
  rtk_float,
  dead_reckoning,
  manual_input,
  simulated;

  static GPSStatus fromInt(int value) => switch (value) {
        0 => GPSStatus.no_fix,
        1 => GPSStatus.two_d_fix,
        2 => GPSStatus.three_d_fix,
        3 => GPSStatus.dgps_fix,
        4 => GPSStatus.rtk_fix,
        5 => GPSStatus.rtk_float,
        6 => GPSStatus.dead_reckoning,
        7 => GPSStatus.manual_input,
        8 => GPSStatus.simulated,
        _ => GPSStatus.no_fix,
      };
}