enum PositionConfidence {
  unavailable,
  a500m,
  a200m,
  a100m,
  a50m,
  a20m,
  a10m,
  a5m,
  a2m,
  a1m,
  a50cm,
  a20cm,
  a10cm,
  a5cm,
  a2cm,
  a1cm;

  double getAsMeters() {
    switch (this) {
      case PositionConfidence.unavailable:
        return 0.0;
      case PositionConfidence.a500m:
        return 500.0;
      case PositionConfidence.a200m:
        return 200.0;
      case PositionConfidence.a100m:
        return 100.0;
      case PositionConfidence.a50m:
        return 50.0;
      case PositionConfidence.a20m:
        return 20.0;
      case PositionConfidence.a10m:
        return 10.0;
      case PositionConfidence.a5m:
        return 5.0;
      case PositionConfidence.a2m:
        return 2.0;
      case PositionConfidence.a1m:
        return 1.0;
      case PositionConfidence.a50cm:
        return 0.5;
      case PositionConfidence.a20cm:
        return 0.2;
      case PositionConfidence.a10cm:
        return 0.1;
      case PositionConfidence.a5cm:
        return 0.05;
      case PositionConfidence.a2cm:
        return 0.02;
      case PositionConfidence.a1cm:
        return 0.01;
    }
  }


}

