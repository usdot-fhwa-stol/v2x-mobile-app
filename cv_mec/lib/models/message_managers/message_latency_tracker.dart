enum LatencyStatus { RENDERED, SUPERSEDED, EXPIRED }

class MessageLatencyTracker {
  final bool enabled;
  Map<Object, DateTime> recTimes = <Object, DateTime>{};
  Map<Object, DateTime> drawnTimes = <Object, DateTime>{};

  MessageLatencyTracker({this.enabled = true});

  DateTime? recordReceived(Object key, DateTime recTime) {
    if (!enabled || drawnTimes.containsKey(key)) {
      return null;
    }
    DateTime? supersededRecTime = recTimes[key];
    recTimes[key] = recTime;
    return supersededRecTime;
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

  // Returns the recTime if `key` was received but never drawn, else null.
  DateTime? clear(Object key) {
    DateTime? recTime = recTimes.remove(key);
    DateTime? drawnTime = drawnTimes.remove(key);
    if (drawnTime != null) {
      return null;
    }
    return recTime;
  }
}
