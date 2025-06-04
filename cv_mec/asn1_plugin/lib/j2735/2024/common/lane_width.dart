class LaneWidth {
  final int laneWidth;

  LaneWidth(this.laneWidth);


  getLaneWidthMeters(){
    return laneWidth / 100.0;
  }
}