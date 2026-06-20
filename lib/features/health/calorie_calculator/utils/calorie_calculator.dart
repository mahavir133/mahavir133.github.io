class CalorieResult {
  final double maintenance;
  final double targetCalories;
  final double difference;
  final String goal;
  final double weeklyChangeKg;

  CalorieResult({
    required this.maintenance,
    required this.targetCalories,
    required this.difference,
    required this.goal,
    required this.weeklyChangeKg,
  });
}

class CalorieCalculator {
  static CalorieResult plan({
    required double maintenanceCalories,
    required String goal, // 'Lose', 'Gain', 'Maintain'
    required double weeklyChangeKg, // e.g. 0.25, 0.5, 1.0
  }) {
    if (maintenanceCalories <= 0) throw Exception("Maintenance must be > 0");
    if (weeklyChangeKg < 0) throw Exception("Weekly change must be >= 0");

    // 1 kg body weight change roughly equals 7700 kcal
    double weeklyDifference = weeklyChangeKg * 7700;
    double dailyDifference = weeklyDifference / 7;

    double targetCalories;
    if (goal.toLowerCase() == 'lose') {
      targetCalories = maintenanceCalories - dailyDifference;
    } else if (goal.toLowerCase() == 'gain') {
      targetCalories = maintenanceCalories + dailyDifference;
    } else {
      targetCalories = maintenanceCalories;
      dailyDifference = 0;
      weeklyChangeKg = 0;
    }

    // Safety checks
    if (goal.toLowerCase() == 'lose' && targetCalories < 1200) {
      // It's generally unsafe to go below 1200 kcal for adults without medical supervision
      // We don't cap it here but we can warn in the UI
    }

    return CalorieResult(
      maintenance: maintenanceCalories,
      targetCalories: targetCalories,
      difference: dailyDifference,
      goal: goal,
      weeklyChangeKg: weeklyChangeKg,
    );
  }
}
