enum ElevationConfidence {
  unavailable ,
  elev_500_00 ,
  elev_200_00 ,
  elev_100_00 ,
  elev_050_00 ,
  elev_020_00 ,
  elev_010_00 ,
  elev_005_00 ,
  elev_002_00 ,
  elev_001_00 ,
  elev_000_50 ,
  elev_000_20 ,
  elev_000_10 ,
  elev_000_05 ,
  elev_000_02 ,
  elev_000_01;


  double getAsMeters() {
    switch (this) {
      case ElevationConfidence.unavailable:
        return 0.0;
      case ElevationConfidence.elev_500_00:
        return 500.0;
      case ElevationConfidence.elev_200_00:
        return 200.0;
      case ElevationConfidence.elev_100_00:
        return 100.0;
      case ElevationConfidence.elev_050_00:
        return 50.0;
      case ElevationConfidence.elev_020_00:
        return 20.0;
      case ElevationConfidence.elev_010_00:
        return 10.0;
      case ElevationConfidence.elev_005_00:
        return 5.0;
      case ElevationConfidence.elev_002_00:
        return 2.0;
      case ElevationConfidence.elev_001_00:
        return 1.0;
      case ElevationConfidence.elev_000_50:
        return 0.5;
      case ElevationConfidence.elev_000_20:
        return 0.2;
      case ElevationConfidence.elev_000_10:
        return 0.1;
      case ElevationConfidence.elev_000_05:
        return 0.05;
      case ElevationConfidence.elev_000_02:
        return 0.02;
      case ElevationConfidence.elev_000_01:
        return 0.01;
    }
  }
}

