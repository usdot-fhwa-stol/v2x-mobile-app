class Elevation {
  late int elevation;

  Elevation(this.elevation);

  Elevation.unknown(){
    elevation = -4096;
  }

  double getDecimalElevation() {
    return elevation * 0.1;
  }
}