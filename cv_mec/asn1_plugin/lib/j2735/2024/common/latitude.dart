class Latitude {
  late int latitude;

  Latitude(this.latitude);

  Latitude.unknown(){
    latitude = 900000001;
  }

  double getDecimalLatitude(){
    return latitude / 1E7;
  }
}