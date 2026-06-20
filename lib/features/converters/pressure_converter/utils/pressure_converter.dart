class PressureConverter {
  static final Map<String, double> _toPascals = {
    'Pa': 1.0,
    'kPa': 1000.0,
    'MPa': 1000000.0,
    'atm': 101325.0,
    'bar': 100000.0,
    'mbar': 100.0,
    'psi': 6894.757293168,
    'mmHg (torr)': 133.322368,
    'inHg': 3386.389,
    'kg/cm²': 98066.5,
  };

  static List<String> get units => _toPascals.keys.toList();

  static double convert(double value, String from, String to) {
    if (from == to) return value;

    double inPa = value * _toPascals[from]!;
    return inPa / _toPascals[to]!;
  }
}
