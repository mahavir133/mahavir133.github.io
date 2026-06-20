import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/bmi_bmr_calculator/utils/bmi_calculator.dart';

void main() {
  group('BmiCalculator', () {
    test('calculate male', () {
      final res = BmiCalculator.calculate(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        gender: 'Male',
        activityMultiplier: 1.2,
      );
      
      expect(res.bmi, closeTo(22.86, 0.01));
      expect(res.bmiCategory, "Normal weight");
      expect(res.bmr, 1673.75);
      expect(res.tdee, closeTo(2008.5, 0.01));
    });

    test('calculate female', () {
      final res = BmiCalculator.calculate(
        weightKg: 65,
        heightCm: 160,
        age: 30,
        gender: 'Female',
        activityMultiplier: 1.55,
      );
      
      expect(res.bmi, closeTo(25.39, 0.01));
      expect(res.bmiCategory, "Overweight");
      expect(res.bmr, 1339.0);
      expect(res.tdee, closeTo(2075.45, 0.01));
    });
  });
}
