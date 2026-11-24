class Velocity{
  late int velocity;

  Velocity(this.velocity);

  Velocity.Unknown(){
    velocity = 8191;
  }

  double getVelocityMps() {
    return velocity * 0.02;
  }
}