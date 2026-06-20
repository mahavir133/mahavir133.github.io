class BacResult {
  final double bac;
  final Duration timeToSober;
  final String status;

  BacResult({
    required this.bac,
    required this.timeToSober,
    required this.status,
  });
}

class BacCalculator {
  static BacResult calculate({
    required String gender,
    required double weightKg,
    required double volumeMl,
    required double abvPercent,
    required double hoursElapsed,
  }) {
    if (weightKg <= 0) throw Exception("Weight must be > 0");

    // Widmark Formula
    double r = gender.toLowerCase() == 'male' ? 0.68 : 0.55;
    double alcoholGrams = volumeMl * (abvPercent / 100.0) * 0.789;
    double weightGrams = weightKg * 1000.0;

    double bac = (alcoholGrams / (weightGrams * r)) * 100.0 - (0.015 * hoursElapsed);
    if (bac < 0) bac = 0;

    double hoursToSober = bac / 0.015;
    Duration timeToSober = Duration(minutes: (hoursToSober * 60).round());

    String status;
    if (bac == 0) {
      status = "Sober";
    } else if (bac < 0.04) {
      status = "Mild Impairment (Relaxation)";
    } else if (bac < 0.08) {
      status = "Increased Impairment (Lowered inhibitions)";
    } else if (bac < 0.15) {
      status = "Severe Impairment (Illegal to drive)";
    } else if (bac < 0.30) {
      status = "Very Severe Impairment (Loss of motor control)";
    } else {
      status = "Life Threatening (Alcohol poisoning risk)";
    }

    return BacResult(bac: bac, timeToSober: timeToSober, status: status);
  }
}
