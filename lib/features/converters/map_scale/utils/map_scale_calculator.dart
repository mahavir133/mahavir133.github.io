class MapScaleCalculator {
  static const Map<String, double> _toMeters = {
    // Map units
    'mm': 0.001,
    'cm': 0.01,
    'inches': 0.0254,
    // Real units
    'meters': 1.0,
    'km': 1000.0,
    'miles': 1609.344,
    'feet': 0.3048,
    'yards': 0.9144,
  };

  static double mapToReal(
    double mapValue,
    String mapUnit,
    double scale,
    String realUnit,
  ) {
    final mapInMeters = mapValue * (_toMeters[mapUnit] ?? 1.0);
    final realInMeters = mapInMeters * scale;
    return realInMeters / (_toMeters[realUnit] ?? 1.0);
  }

  static double realToMap(
    double realValue,
    String realUnit,
    double scale,
    String mapUnit,
  ) {
    final realInMeters = realValue * (_toMeters[realUnit] ?? 1.0);
    final mapInMeters = realInMeters / scale;
    return mapInMeters / (_toMeters[mapUnit] ?? 1.0);
  }
}
