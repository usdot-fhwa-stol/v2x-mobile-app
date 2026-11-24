enum SpeedConfidence {
  unavailable,
  prec100ms,
  prec10ms,
  prec5ms,
  prec1ms,
  prec0_1ms,
  prec0_05ms,
  prec0_01ms;

  double getAsMps(){
    switch (this) {
      case SpeedConfidence.unavailable:
        return 0.0;
      case SpeedConfidence.prec100ms:
        return 0.1;
      case SpeedConfidence.prec10ms:
        return 0.01;
      case SpeedConfidence.prec5ms:
        return 0.005;
      case SpeedConfidence.prec1ms:
        return 0.001;
      case SpeedConfidence.prec0_1ms:
        return 0.0001;
      case SpeedConfidence.prec0_05ms:
        return 0.00005;
      case SpeedConfidence.prec0_01ms:
        return 0.00001;
    }
  }
}