class SpeedConverter {
  static final Map<String, double> _toMetersPerSecond = {
    'm/s': 1.0,
    'km/h': 1 / 3.6,
    'mph': 0.44704,
    'ft/s': 0.3048,
    'knots': 0.514444,
    'Mach': 343.0, // standard sea level 20C
    'Speed of Light (c)': 299792458.0,
  };

  static List<String> get units => _toMetersPerSecond.keys.toList();

  static double convert(double value, String from, String to) {
    if (from == to) return value;

    // Convert to m/s
    double inMs = value * _toMetersPerSecond[from]!;

    // Convert from m/s to target
    return inMs / _toMetersPerSecond[to]!;
  }
}
