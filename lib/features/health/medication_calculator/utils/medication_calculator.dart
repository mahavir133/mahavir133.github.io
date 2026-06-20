class MedicationResult {
  final double totalDoseMg;
  final double? volumeMl;

  MedicationResult({
    required this.totalDoseMg,
    this.volumeMl,
  });
}

class MedicationCalculator {
  static MedicationResult calculate({
    required double weightKg,
    required double dosePerKgMg,
    double? concentrationMgPerMl,
  }) {
    if (weightKg <= 0 || dosePerKgMg <= 0) {
      throw Exception("Weight and Dose per kg must be greater than zero");
    }
    if (concentrationMgPerMl != null && concentrationMgPerMl <= 0) {
      throw Exception("Concentration must be greater than zero");
    }

    double totalDoseMg = weightKg * dosePerKgMg;
    double? volumeMl;

    if (concentrationMgPerMl != null) {
      volumeMl = totalDoseMg / concentrationMgPerMl;
    }

    return MedicationResult(
      totalDoseMg: totalDoseMg,
      volumeMl: volumeMl,
    );
  }
}
