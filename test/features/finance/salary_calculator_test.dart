import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/salary_calculator/utils/salary_calculator.dart';

void main() {
  group('SalaryCalculator', () {
    test('calculates from yearly correctly', () {
      final result = SalaryCalculator.calculate(
        amount: 120000,
        frequency: SalaryFrequency.yearly,
        hoursPerWeek: 40,
        daysPerWeek: 5,
      );

      expect(result.monthly, 10000);
      expect(result.weekly, closeTo(2307.69, 0.01));
      expect(result.hourly, closeTo(57.69, 0.01));
    });

    test('calculates from hourly correctly', () {
      final result = SalaryCalculator.calculate(
        amount: 50,
        frequency: SalaryFrequency.hourly,
        hoursPerWeek: 40,
        daysPerWeek: 5,
      );

      expect(result.yearly, 104000); // 50 * 40 * 52
      expect(result.weekly, 2000);
    });
  });
}
