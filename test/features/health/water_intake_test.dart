import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/water_intake_calculator/utils/water_intake_calculator.dart';

void main() {
  group('WaterIntakeCalculator', () {
    test('calculate moderate', () {
      final ml = WaterIntakeCalculator.calculateMl(
        weightKg: 70,
        climate: 'Moderate',
        activityLevel: 'Sedentary',
      );
      // 70 * 35 = 2450
      expect(ml, 2450);
    });

    test('calculate hot and active', () {
      final ml = WaterIntakeCalculator.calculateMl(
        weightKg: 80,
        climate: 'Hot',
        activityLevel: 'Active',
      );
      // 80 * 35 = 2800 + 500 + 800 = 4100
      expect(ml, 4100);
    });
  });
}
