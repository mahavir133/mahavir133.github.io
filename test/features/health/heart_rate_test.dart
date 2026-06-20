import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/heart_rate_calculator/utils/heart_rate_calculator.dart';

void main() {
  group('HeartRateCalculator', () {
    test('calculate standard', () {
      final res = HeartRateCalculator.calculateZones(age: 30);
      expect(res.maxHr, 187); // 208 - (0.7 * 30) = 208 - 21 = 187
      expect(res.zones[0].minHr, 94); // 50%
      expect(res.zones.last.maxHr, 187); // 100%
    });

    test('calculate karvonen', () {
      final res = HeartRateCalculator.calculateZones(age: 30, restingHr: 60);
      // HRR = 187 - 60 = 127. 50% = 63.5 + 60 = 124
      expect(res.maxHr, 187);
      expect(res.zones[0].minHr, 124);
    });
  });
}
