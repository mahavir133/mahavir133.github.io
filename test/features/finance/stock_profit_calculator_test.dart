import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/stock_profit_calculator/utils/stock_profit_calculator.dart';

void main() {
  group('StockProfitCalculator', () {
    test('calculates profit correctly with fees', () {
      final result = StockProfitCalculator.calculate(
        buyPrice: 100,
        sellPrice: 150,
        quantity: 10,
        buyFees: 5,
        sellFees: 5,
      );

      // Invested: (100 * 10) + 5 = 1005
      // Revenue: (150 * 10) - 5 = 1495
      // Profit: 1495 - 1005 = 490
      
      expect(result.totalInvested, 1005);
      expect(result.totalRevenue, 1495);
      expect(result.profitOrLoss, 490);
      expect(result.isProfit, true);
    });

    test('calculates loss correctly with fees', () {
      final result = StockProfitCalculator.calculate(
        buyPrice: 100,
        sellPrice: 80,
        quantity: 10,
        buyFees: 5,
        sellFees: 5,
      );

      // Invested: 1005
      // Revenue: 795
      // Loss: 210

      expect(result.totalInvested, 1005);
      expect(result.totalRevenue, 795);
      expect(result.profitOrLoss, 210);
      expect(result.isProfit, false);
    });
  });
}
