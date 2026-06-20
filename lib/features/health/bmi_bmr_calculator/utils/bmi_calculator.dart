class BmiResult {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;

  BmiResult({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
  });
}

class BmiCalculator {
  static BmiResult calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required double activityMultiplier,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) {
      throw Exception("Weight, height, and age must be greater than zero.");
    }

    double heightM = heightCm / 100.0;
    double bmi = weightKg / (heightM * heightM);

    String category;
    if (bmi < 18.5) {
      category = "Underweight";
    } else if (bmi < 25) {
      category = "Normal weight";
    } else if (bmi < 30) {
      category = "Overweight";
    } else {
      category = "Obese";
    }

    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    double tdee = bmr * activityMultiplier;

    return BmiResult(
      bmi: bmi,
      bmiCategory: category,
      bmr: bmr,
      tdee: tdee,
    );
  }
}
