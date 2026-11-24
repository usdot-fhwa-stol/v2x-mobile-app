enum HeadingConfidence {
  unavailable,
  prec10deg,
  prec05deg,
  prec01deg,
  prec0_1deg,
  prec0_05deg,
  prec0_01deg,
  prec0_0125deg;


  double getAsDegrees(){
    switch (this) {
      case HeadingConfidence.unavailable:
        return 0.0;
      case HeadingConfidence.prec10deg:
        return 10.0;
      case HeadingConfidence.prec05deg:
        return 5.0;
      case HeadingConfidence.prec01deg:
        return 1.0;
      case HeadingConfidence.prec0_1deg:
        return 0.1;
      case HeadingConfidence.prec0_05deg:
        return 0.05;
      case HeadingConfidence.prec0_01deg:
        return 0.01;
      case HeadingConfidence.prec0_0125deg:
        return 0.0125;
    }
  }
}