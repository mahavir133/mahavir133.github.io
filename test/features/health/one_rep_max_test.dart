import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/one_rep_max_calculator/utils/one_rep_max_calculator.dart';

void main() {
  group('OneRepMaxCalculator', () {
    test('calculate 1RM', () {
      final res = OneRepMaxCalculator.calculate(100, 5); // 100 for 5 reps
      expect(res.epley, closeTo(116.66, 0.1));
      expect(res.brzycki, closeTo(112.5, 0.1));
      expect(res.lombardi, closeTo(117.46, 0.1));
      expect(res.percentages[100], res.average);
      expect(res.percentages[50], res.average * 0.5);
    });
  });
}
