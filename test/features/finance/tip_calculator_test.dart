import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/tip_calculator/utils/tip_calculator.dart';

void main() {
  group('TipCalculator', () {
    test('calculates correct tip and split', () {
      final result = TipCalculator.calculate(
        billAmount: 100,
        tipPercentage: 15,
        numberOfPeople: 2,
      );

      expect(result.tipAmount, 15);
      expect(result.totalBill, 115);
      expect(result.perPersonAmount, 57.5);
    });

    test('handles 0% tip correctly', () {
      final result = TipCalculator.calculate(
        billAmount: 50,
        tipPercentage: 0,
        numberOfPeople: 1,
      );

      expect(result.tipAmount, 0);
      expect(result.totalBill, 50);
      expect(result.perPersonAmount, 50);
    });
  });
}
