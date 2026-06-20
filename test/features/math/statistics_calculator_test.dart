import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/statistics_calculator/utils/statistics_calculator.dart';

void main() {
  group('StatisticsCalculator', () {
    test('single data', () {
      final res = StatisticsCalculator.calculateSingle([1, 2, 3, 4, 5, 5]);
      expect(res.mean, closeTo(3.333, 0.001));
      expect(res.median, 3.5);
      expect(res.mode, [5]);
      expect(res.variance, closeTo(2.666, 0.001));
      expect(res.stdDev, closeTo(1.632, 0.001));
      expect(res.q1, closeTo(2.25, 0.001));
      expect(res.q3, closeTo(4.75, 0.001));
    });

    test('regression', () {
      final res = StatisticsCalculator.calculateRegression([1, 2, 3], [2, 4, 6]);
      expect(res.slope, 2.0);
      expect(res.intercept, 0.0);
      expect(res.correlation, 1.0);
    });
  });
}
