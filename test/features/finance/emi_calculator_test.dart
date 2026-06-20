import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/emi_calculator/utils/emi_calculator.dart';

void main() {
  group('EmiCalculator', () {
    test('calculates correct EMI for valid inputs', () {
      final result = EmiCalculator.calculate(
        principal: 100000,
        annualInterestRate: 10,
        tenureMonths: 12,
      );

      // EMI should be around 8791.59
      expect(result.emi, closeTo(8791.59, 0.01));
      expect(result.totalPayment, closeTo(105499.06, 0.01));
      expect(result.totalInterest, closeTo(5499.06, 0.01));
      expect(result.amortizationTable.length, 12);
    });

    test('handles 0% interest rate', () {
      final result = EmiCalculator.calculate(
        principal: 120000,
        annualInterestRate: 0,
        tenureMonths: 12,
      );

      expect(result.emi, 10000);
      expect(result.totalInterest, 0);
      expect(result.totalPayment, 120000);
    });

    test('handles 0 principal', () {
      final result = EmiCalculator.calculate(
        principal: 0,
        annualInterestRate: 10,
        tenureMonths: 12,
      );

      expect(result.emi, 0);
    });
  });
}
