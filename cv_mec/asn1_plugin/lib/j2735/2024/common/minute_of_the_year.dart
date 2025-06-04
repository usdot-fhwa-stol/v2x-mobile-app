class MinuteOfTheYear {
  late int minuteOfTheYear;

  MinuteOfTheYear(this.minuteOfTheYear);

  MinuteOfTheYear.empty() : minuteOfTheYear = 527040;

  DateTime getUtcMinute(DateTime referenceTime) {
    return DateTime(referenceTime.year).add(Duration(minutes: minuteOfTheYear));
  }
}
