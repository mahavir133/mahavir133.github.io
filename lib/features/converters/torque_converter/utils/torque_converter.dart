class TorqueConverter {
  static final Map<String, double> _toNm = {
    'Nm': 1.0,
    'ft-lb': 1.355818,
    'in-lb': 0.1129848,
    'kgf-m': 9.80665,
    'kg-cm': 0.0980665,
    'dyne-cm': 0.0000001,
  };

  static List<String> get units => _toNm.keys.toList();

  static double convert(double value, String from, String to) {
    if (from == to) return value;

    double inNm = value * _toNm[from]!;
    return inNm / _toNm[to]!;
  }
}
