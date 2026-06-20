class PaintResult {
  final double netWallArea;
  final double totalPaintLiters;
  final double totalPaintGallons;

  PaintResult({
    required this.netWallArea,
    required this.totalPaintLiters,
    required this.totalPaintGallons,
  });
}

class PaintLogic {
  static PaintResult calculate({
    required double roomLength,
    required double roomWidth,
    required double roomHeight,
    required int numDoors,
    required int numWindows,
    required int coats,
    required double coveragePerUnit, // sq m per liter OR sq ft per gallon
    required bool isMetric,
  }) {
    // Gross Wall Area = Perimeter * Height
    double perimeter = 2 * (roomLength + roomWidth);
    double grossArea = perimeter * roomHeight;

    // Standard deductions
    // Metric: Door ≈ 1.85 m², Window ≈ 1.1 m²
    // Imperial: Door ≈ 20 sq ft, Window ≈ 12 sq ft
    double doorArea = isMetric ? 1.85 : 20.0;
    double windowArea = isMetric ? 1.1 : 12.0;

    double totalDeductions = (numDoors * doorArea) + (numWindows * windowArea);

    double netArea = grossArea - totalDeductions;
    if (netArea < 0) netArea = 0;

    // Total area to paint across all coats
    double totalAreaToPaint = netArea * coats;

    // Calculate paint volume based on coverage
    // If metric, coverage is m²/liter. Result is liters.
    // If imperial, coverage is sq ft/gallon. Result is gallons.
    double paintLiters = 0;
    double paintGallons = 0;

    if (coveragePerUnit > 0) {
      if (isMetric) {
        paintLiters = totalAreaToPaint / coveragePerUnit;
        paintGallons = paintLiters * 0.264172; // 1 L = 0.264172 Gal
      } else {
        paintGallons = totalAreaToPaint / coveragePerUnit;
        paintLiters = paintGallons * 3.78541; // 1 Gal = 3.78541 L
      }
    }

    return PaintResult(
      netWallArea: netArea,
      totalPaintLiters: paintLiters,
      totalPaintGallons: paintGallons,
    );
  }
}
