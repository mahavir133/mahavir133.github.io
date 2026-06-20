import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/discount_calculator/utils/discount_calculator.dart';

void main() {
  group('DiscountCalculator', () {
    test('calculates single discount correctly', () {
      final result = DiscountCalculator.calculate(
        originalPrice: 100,
        discount1: 20,
        discount2: 0,
      );

      expect(result.finalPrice, 80);
      expect(result.savings, 20);
    });

    test('calculates chain discount correctly', () {
      final result = DiscountCalculator.calculate(
        originalPrice: 100,
        discount1: 20,
        discount2: 10,
      );

      // 100 - 20% = 80. 80 - 10% = 72. Total savings = 28.
      expect(result.finalPrice, 72);
      expect(result.savings, 28);
    });
  });
}
