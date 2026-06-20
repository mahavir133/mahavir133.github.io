import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/tax_calculator/utils/tax_calculator.dart';

void main() {
  group('TaxCalculator', () {
    test('calculates exclusive tax correctly', () {
      final result = TaxCalculator.calculate(
        amount: 100,
        taxRate: 15,
        isTaxInclusive: false,
      );

      expect(result.netAmount, 100);
      expect(result.taxAmount, 15);
      expect(result.grossAmount, 115);
    });

    test('calculates inclusive tax correctly', () {
      final result = TaxCalculator.calculate(
        amount: 115,
        taxRate: 15,
        isTaxInclusive: true,
      );

      expect(result.netAmount, closeTo(100, 0.01));
      expect(result.taxAmount, closeTo(15, 0.01));
      expect(result.grossAmount, 115);
    });

    test('handles zero tax rate', () {
      final result = TaxCalculator.calculate(
        amount: 100,
        taxRate: 0,
        isTaxInclusive: false,
      );

      expect(result.taxAmount, 0);
      expect(result.grossAmount, 100);
    });
  });
}
