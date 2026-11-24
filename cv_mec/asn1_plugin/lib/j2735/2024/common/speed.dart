class Speed{
  late int speed;

  Speed(this.speed);

  double getSpeedMps(){
    return speed * 0.02;
  }
}