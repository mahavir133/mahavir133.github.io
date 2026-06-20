class AccelerationConverter {
  static final Map<String, double> _toMetersPerSecondSquared = {
    'm/s²': 1.0,
    'ft/s²': 0.3048,
    'g-force (g)': 9.80665,
    'Gal (cm/s²)': 0.01,
    'cm/s²': 0.01,
  };

  static List<String> get units => _toMetersPerSecondSquared.keys.toList();

  static double convert(double value, String from, String to) {
    if (from == to) return value;

    // Convert to m/s²
    double inMs2 = value * _toMetersPerSecondSquared[from]!;

    // Convert from m/s² to target
    return inMs2 / _toMetersPerSecondSquared[to]!;
  }
}
