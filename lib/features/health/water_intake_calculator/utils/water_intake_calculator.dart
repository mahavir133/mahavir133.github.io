class WaterIntakeCalculator {
  static double calculateMl({
    required double weightKg,
    required String climate,
    required String activityLevel,
  }) {
    if (weightKg <= 0) {
      throw Exception("Weight must be greater than zero.");
    }

    // Base calculation: 35ml per kg of body weight
    double baseMl = weightKg * 35.0;

    // Climate adjustment
    if (climate.toLowerCase() == 'hot') {
      baseMl += 500;
    } else if (climate.toLowerCase() == 'cold') {
      baseMl -= 250; // Less sweating, though still need hydration
    }

    // Activity adjustment
    if (activityLevel.toLowerCase() == 'moderate') {
      baseMl += 400;
    } else if (activityLevel.toLowerCase() == 'active') {
      baseMl += 800;
    } else if (activityLevel.toLowerCase() == 'very active') {
      baseMl += 1200;
    }

    // Ensure it doesn't go below a bare minimum survival baseline
    if (baseMl < 1500) {
      baseMl = 1500;
    }

    return baseMl;
  }
}
