import 'dart:math';

class RoofResult {
  final double rafterLength;
  final double roofArea;
  final int shinglesNeeded;
  final double ridgeLength;

  RoofResult({
    required this.rafterLength,
    required this.roofArea,
    required this.shinglesNeeded,
    required this.ridgeLength,
  });
}

class RoofLogic {
  static RoofResult calculate({
    required double baseLength,
    required double baseWidth,
    required double overhang,
    required double
    pitch, // If metric, it's degrees. If imperial, it's X in X:12.
    required bool isMetric,
  }) {
    double pitchMultiplier;

    if (isMetric) {
      // Pitch is in degrees. Make sure it's < 90
      if (pitch >= 90) pitch = 89;
      // Multiplier = secant(angle) = 1 / cos(angle)
      double radians = pitch * pi / 180.0;
      pitchMultiplier = 1 / cos(radians);
    } else {
      // Pitch is X:12
      pitchMultiplier = sqrt(pow(pitch / 12, 2) + 1);
    }

    // Horizontal run from center to edge of overhang
    double run = (baseWidth / 2) + overhang;

    // Rafter Length
    double rafterLength = run * pitchMultiplier;

    // Ridge Length (simple gable roof)
    double ridgeLength = baseLength + (2 * overhang);

    // Roof Area (two sides)
    double roofArea = ridgeLength * rafterLength * 2;

    // Number of shingles (1 bundle covers ~33.3 sq ft) -> 3 bundles per "Square" (100 sq ft)
    // In metric, 1 bundle covers ~3.1 sq meters. Let's just output bundles based on area.
    // Actually, shingles is often asked. Let's do bundles.
    int bundles;
    if (isMetric) {
      bundles = (roofArea / 3.1).ceil();
    } else {
      bundles = (roofArea / 33.33).ceil();
    }

    // Add 10% wastage
    bundles = (bundles * 1.1).ceil();

    return RoofResult(
      rafterLength: rafterLength,
      roofArea: roofArea,
      shinglesNeeded: bundles, // Represents Bundles
      ridgeLength: ridgeLength,
    );
  }
}
