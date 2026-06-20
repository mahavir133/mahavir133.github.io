class BrickResult {
  final int totalBricks;
  final double wallArea;
  final double mortarVolumeCubicMeters;
  final double mortarVolumeCubicFeet;

  BrickResult({
    required this.totalBricks,
    required this.wallArea,
    required this.mortarVolumeCubicMeters,
    required this.mortarVolumeCubicFeet,
  });
}

class BrickLogic {
  static BrickResult calculate({
    required double wallLength,
    required double wallHeight,
    required double brickLength,
    required double brickHeight,
    required double brickDepth,
    required double mortarThickness,
    required double openingsArea,
    required double wastagePercent,
    required bool isMetric,
  }) {
    // We do calculations in meters internally
    double wL = isMetric ? wallLength : wallLength * 0.3048;
    double wH = isMetric ? wallHeight : wallHeight * 0.3048;
    // Brick dimensions are usually in mm (metric) or inches (imperial)
    // We assume the inputs for brick dimensions are in MM for metric, INCHES for imperial
    double bL = isMetric ? brickLength / 1000 : brickLength * 0.0254;
    double bH = isMetric ? brickHeight / 1000 : brickHeight * 0.0254;
    double bD = isMetric ? brickDepth / 1000 : brickDepth * 0.0254;
    double m = isMetric ? mortarThickness / 1000 : mortarThickness * 0.0254;

    // Openings
    double openings = isMetric ? openingsArea : openingsArea * 0.092903;

    double wallAreaGross = wL * wH;
    double wallAreaNet = wallAreaGross - openings;
    if (wallAreaNet < 0) wallAreaNet = 0;

    // Area of one brick with mortar
    double brickAreaWithMortar = (bL + m) * (bH + m);

    if (brickAreaWithMortar == 0)
      return BrickResult(
        totalBricks: 0,
        wallArea: 0,
        mortarVolumeCubicMeters: 0,
        mortarVolumeCubicFeet: 0,
      );

    double numberOfBricksRaw = wallAreaNet / brickAreaWithMortar;

    // Add wastage
    double totalBricksWithWastage =
        numberOfBricksRaw * (1 + (wastagePercent / 100));

    // Mortar Volume calculation
    // Volume of wall = wallAreaNet * brickDepth
    // Volume of bricks = numberOfBricksRaw * (bL * bH * bD)
    // Mortar volume = Volume of wall - Volume of bricks
    double wallVolume = wallAreaNet * bD;
    double pureBricksVolume = numberOfBricksRaw * (bL * bH * bD);
    double mortarVolumeRaw = wallVolume - pureBricksVolume;
    if (mortarVolumeRaw < 0) mortarVolumeRaw = 0;

    // Add wastage to mortar as well
    double mortarWithWastage = mortarVolumeRaw * (1 + (wastagePercent / 100));

    double wallAreaDisplay = isMetric
        ? wallAreaNet
        : wallAreaNet / 0.092903; // m2 or sq ft

    return BrickResult(
      totalBricks: totalBricksWithWastage.ceil(),
      wallArea: wallAreaDisplay,
      mortarVolumeCubicMeters: mortarWithWastage,
      mortarVolumeCubicFeet: mortarWithWastage * 35.3147,
    );
  }
}
