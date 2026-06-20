import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/compound_interest_calculator/utils/compound_interest_calculator.dart';

void main() {
  group('CompoundInterestCalculator', () {
    test('calculates annual compounding correctly', () {
      final result = CompoundInterestCalculator.calculate(
        principal: 1000,
        annualRate: 5,
        timeInYears: 10,
        compoundingFrequencyPerYear: 1, // Annual
      );

      expect(result.totalAmount, closeTo(1628.89, 0.01));
      expect(result.totalInterest, closeTo(628.89, 0.01));
    });

    test('calculates monthly compounding correctly', () {
      final result = CompoundInterestCalculator.calculate(
        principal: 5000,
        annualRate: 5,
        timeInYears: 10,
        compoundingFrequencyPerYear: 12, // Monthly
      );

      expect(result.totalAmount, closeTo(8235.05, 0.01));
      expect(result.totalInterest, closeTo(3235.05, 0.01));
    });
  });
}
