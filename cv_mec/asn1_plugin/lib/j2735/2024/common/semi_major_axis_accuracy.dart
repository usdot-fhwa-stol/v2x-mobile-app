class SemiMajorAxisAccuracy {
  int semiMajorAxisAccuracy;

  SemiMajorAxisAccuracy(this.semiMajorAxisAccuracy);

  double getDecimalAccuracy() {
    return semiMajorAxisAccuracy * 0.05;
  }
}