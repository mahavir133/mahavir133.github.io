class TileResult {
  final double roomArea;
  final int totalTiles;
  final double estimatedCost;

  TileResult({
    required this.roomArea,
    required this.totalTiles,
    required this.estimatedCost,
  });
}

class TileLogic {
  static TileResult calculate({
    required double roomLength, // meters or ft
    required double roomWidth, // meters or ft
    required double tileLength, // mm or inches
    required double tileWidth, // mm or inches
    required double groutWidth, // mm or inches
    required double wastagePercent,
    required double costPerTile,
    required bool isMetric,
  }) {
    double rL = roomLength;
    double rW = roomWidth;
    double roomArea = rL * rW;

    // Convert tile dimensions to the same unit as room
    // Metric: mm -> meters
    // Imperial: inches -> feet
    double tL = isMetric ? (tileLength / 1000.0) : (tileLength / 12.0);
    double tW = isMetric ? (tileWidth / 1000.0) : (tileWidth / 12.0);
    double gW = isMetric ? (groutWidth / 1000.0) : (groutWidth / 12.0);

    // Effective tile size including half grout on all sides (so 1 full grout joint)
    double effectiveTileLength = tL + gW;
    double effectiveTileWidth = tW + gW;

    double effectiveTileArea = effectiveTileLength * effectiveTileWidth;

    if (effectiveTileArea == 0)
      return TileResult(roomArea: 0, totalTiles: 0, estimatedCost: 0);

    double tilesRaw = roomArea / effectiveTileArea;
    int totalTiles = (tilesRaw * (1 + (wastagePercent / 100))).ceil();

    double cost = totalTiles * costPerTile;

    return TileResult(
      roomArea: roomArea,
      totalTiles: totalTiles,
      estimatedCost: cost,
    );
  }
}
