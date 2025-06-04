class DSecond {
  late int dSecond;

  DSecond(this.dSecond);

  // Returns a DateTime as if the Dsecond was the second of the reference time.
  DateTime getDateTime(DateTime refTime) {
    DateTime dt = DateTime.utc(refTime.year, refTime.month, refTime.day,
        refTime.hour, refTime.minute, dSecond ~/ 1000);
    dt = dt.add(Duration(milliseconds: dSecond % 1000));
    if (dSecond > 55000 && refTime.second < 5) {
      // handle case where the dSecond is in the previous minute
      dt = dt.subtract(const Duration(minutes: 1));
    }

    return dt;
  }
}
