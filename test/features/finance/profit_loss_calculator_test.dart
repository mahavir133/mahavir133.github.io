import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/profit_loss_calculator/utils/profit_loss_calculator.dart';

void main() {
  group('ProfitLossCalculator', () {
    test('calculates profit correctly', () {
      final result = ProfitLossCalculator.calculate(
        costPrice: 80,
        sellingPrice: 100,
      );

      expect(result.profitOrLoss, 20);
      expect(result.isProfit, true);
      expect(result.marginPercentage, 20);
      expect(result.markupPercentage, 25);
    });

    test('calculates loss correctly', () {
      final result = ProfitLossCalculator.calculate(
        costPrice: 100,
        sellingPrice: 80,
      );

      expect(result.profitOrLoss, 20);
      expect(result.isProfit, false);
      expect(result.marginPercentage, 25); // 20 / 80
      expect(result.markupPercentage, 20); // 20 / 100
    });
  });
}
