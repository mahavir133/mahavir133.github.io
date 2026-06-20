import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/finance/depreciation_calculator/utils/depreciation_calculator.dart';

void main() {
  group('DepreciationCalculator', () {
    test('calculates straight line correctly', () {
      final result = DepreciationCalculator.calculateStraightLine(
        assetCost: 10000,
        salvageValue: 2000,
        usefulLife: 4,
      );

      expect(result.totalDepreciation, 8000);
      expect(result.table.length, 4);
      expect(result.table[0].depreciationExpense, 2000);
      expect(result.table[3].bookValue, 2000); // Equal to salvage value at end
    });
  });
}
