class MessageLatencyTracker {
  Map<Object, DateTime> recTimes = <Object, DateTime>{};
  Map<Object, DateTime> drawnTimes = <Object, DateTime>{};

  void recordReceived(Object key, DateTime recTime) {
    recTimes[key] = recTime;
    drawnTimes.remove(key);
  }

  // Returns the recTime if this is the first draw since the last recordReceived for `key`, else null.
  DateTime? recordDrawn(Object key, DateTime drawnTime) {
    if (drawnTimes.containsKey(key)) {
      return null;
    }
    DateTime? recTime = recTimes[key];
    if (recTime == null) {
      return null;
    }
    drawnTimes[key] = drawnTime;
    return recTime;
  }

  void clear(Object key) {
    recTimes.remove(key);
    drawnTimes.remove(key);
  }
}