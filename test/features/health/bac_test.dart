import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/bac_calculator/utils/bac_calculator.dart';

void main() {
  group('BacCalculator', () {
    test('calculate bac', () {
      final res = BacCalculator.calculate(
        gender: 'Male',
        weightKg: 80,
        volumeMl: 500, // 500ml beer
        abvPercent: 5.0, // 5%
        hoursElapsed: 1.0,
      );
      // Alcohol grams = 500 * 0.05 * 0.789 = 19.725
      // BAC = (19.725 / (80000 * 0.68)) * 100 - 0.015
      // = (19.725 / 54400) * 100 - 0.015
      // = 0.03625 - 0.015 = 0.02125
      expect(res.bac, closeTo(0.021, 0.005));
    });
  });
}
