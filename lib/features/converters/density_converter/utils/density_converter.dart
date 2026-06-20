class DensityConverter {
  static final Map<String, double> _toKgM3 = {
    'kg/m³': 1.0,
    'g/cm³': 1000.0,
    'kg/L': 1000.0,
    'lb/ft³': 16.018463,
    'lb/in³': 27679.904,
    'oz/gal (US)': 7.489152,
  };

  static List<String> get units => _toKgM3.keys.toList();

  static double convert(double value, String from, String to) {
    if (from == to) return value;

    double inKg = value * _toKgM3[from]!;
    return inKg / _toKgM3[to]!;
  }
}
