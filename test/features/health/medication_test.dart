import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/health/medication_calculator/utils/medication_calculator.dart';

void main() {
  group('MedicationCalculator', () {
    test('calculate solid dose', () {
      final res = MedicationCalculator.calculate(
        weightKg: 20,
        dosePerKgMg: 15,
      );
      expect(res.totalDoseMg, 300);
      expect(res.volumeMl, isNull);
    });

    test('calculate liquid dose', () {
      final res = MedicationCalculator.calculate(
        weightKg: 20,
        dosePerKgMg: 15,
        concentrationMgPerMl: 50, // 50mg per 1ml
      );
      expect(res.totalDoseMg, 300);
      expect(res.volumeMl, 6.0);
    });
  });
}
