import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/calorie_calculator/utils/calorie_calculator.dart';

void main() {
  group('CalorieCalculator', () {
    test('lose weight', () {
      final res = CalorieCalculator.plan(
        maintenanceCalories: 2500,
        goal: 'Lose',
        weeklyChangeKg: 0.5,
      );
      // 0.5 * 7700 / 7 = 550
      // target = 2500 - 550 = 1950
      expect(res.difference, 550);
      expect(res.targetCalories, 1950);
    });
  });
}
