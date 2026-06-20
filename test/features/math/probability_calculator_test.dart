import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/probability_calculator/utils/probability_calculator.dart';

void main() {
  group('ProbabilityCalculator', () {
    test('permutations', () {
      expect(ProbabilityCalculator.permutations(5, 3), 60);
    });

    test('combinations', () {
      expect(ProbabilityCalculator.combinations(5, 3), 10);
    });

    test('binomial', () {
      expect(ProbabilityCalculator.binomial(10, 5, 0.5), closeTo(0.24609, 0.0001));
    });

    test('poisson', () {
      expect(ProbabilityCalculator.poisson(3.0, 2), closeTo(0.2240, 0.0001));
    });
  });
}
