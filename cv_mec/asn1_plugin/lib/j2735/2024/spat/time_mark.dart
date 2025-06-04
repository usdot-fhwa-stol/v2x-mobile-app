class TimeMark {
  late int timeMark;

  TimeMark(this.timeMark);

  DateTime getUtcTime(DateTime referenceTime) {
    // DateTime newTime = referenceTime.add(Duration(milliseconds: timeMark * 100));

    DateTime newTime = DateTime.utc(referenceTime.year, referenceTime.month,
        referenceTime.day, referenceTime.hour, 0, 0, 0);
    if (referenceTime.minute > 50 && timeMark < 6000) {
      newTime = newTime.add(const Duration(hours: 1));
    }
    newTime = newTime.add(Duration(milliseconds: timeMark * 100));
    return newTime;
  }
}
