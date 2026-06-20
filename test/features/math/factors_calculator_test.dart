import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/factors_calculator/utils/factors_calculator.dart';

void main() {
  group('FactorsCalculator', () {
    test('calculates GCD and LCM', () {
      final result = FactorsCalculator.calculateMulti([12, 15, 21]);
      expect(result.gcd, 3);
      expect(result.lcm, 420);
    });

    test('calculates prime factorization', () {
      final result = FactorsCalculator.primeFactorization(60);
      expect(result.primeFactors, [2, 2, 3, 5]);
    });
  });
}
