import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/body_fat_calculator/utils/body_fat_calculator.dart';

void main() {
  group('BodyFatCalculator', () {
    test('navy method male', () {
      final bf = BodyFatCalculator.calculateNavyMethod(
        gender: 'Male',
        heightCm: 178,
        neckCm: 38,
        waistCm: 84,
      );
      // Expected around ~15%
      expect(bf, closeTo(14.8, 1.0));
    });

    test('navy method female', () {
      final bf = BodyFatCalculator.calculateNavyMethod(
        gender: 'Female',
        heightCm: 165,
        neckCm: 34,
        waistCm: 70,
        hipCm: 95,
      );
      // Expected around ~25%
      expect(bf, closeTo(24.8, 1.0));
    });
  });
}
