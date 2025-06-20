class RegionArea {
  double? minX;
  double? maxX;
  double? minY;
  double? maxY;

  RegionArea({this.minX, this.maxX, this.minY, this.maxY});

  bool get anyEmpty {
    return minX == null || minY == null || maxX == null || maxY == null;
  }
}
