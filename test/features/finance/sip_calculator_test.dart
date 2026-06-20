import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/sip_calculator/utils/sip_calculator.dart';

void main() {
  group('SipCalculator', () {
    test('calculates correct SIP for valid inputs', () {
      final result = SipCalculator.calculateSip(
        monthlyInvestment: 10000,
        annualReturnRate: 12,
        tenureYears: 10,
      );

      expect(result.investedAmount, 1200000);
      expect(result.totalValue, closeTo(2323390.81, 100)); // Approx 23.23 Lakhs
      expect(result.estimatedReturns, closeTo(1123390.81, 100));
      expect(result.yearlyTable.length, 10);
    });

    test('handles 0% return rate', () {
      final result = SipCalculator.calculateSip(
        monthlyInvestment: 5000,
        annualReturnRate: 0,
        tenureYears: 5,
      );

      expect(result.investedAmount, 300000);
      expect(result.estimatedReturns, 0);
      expect(result.totalValue, 300000);
    });
  });
}
