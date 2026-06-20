import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/pace_calculator/utils/pace_calculator.dart';

void main() {
  group('PaceCalculator', () {
    test('calculate time from distance and pace', () {
      final res = PaceCalculator.calculate(
        distanceKm: 5.0, // 5k
        pacePerKm: const Duration(minutes: 5, seconds: 0), // 5:00 min/km
      );
      expect(res.time.inMinutes, 25);
      expect(res.speedKmh, 12.0);
    });

    test('calculate pace from distance and time', () {
      final res = PaceCalculator.calculate(
        distanceKm: 10.0,
        time: const Duration(minutes: 50, seconds: 0), // 50 min 10k
      );
      expect(res.pacePerKm.inMinutes, 5);
      expect(res.pacePerKm.inSeconds % 60, 0); // 5:00/km
    });
  });
}
