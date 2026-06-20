import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/complex_calculator/utils/complex_calculator.dart';
import 'dart:math';

void main() {
  group('ComplexNumber', () {
    test('addition', () {
      final a = ComplexNumber(2, 3);
      final b = ComplexNumber(1, -1);
      final res = a + b;
      expect(res.real, 3);
      expect(res.imaginary, 2);
    });

    test('multiplication', () {
      final a = ComplexNumber(2, 3);
      final b = ComplexNumber(1, -1);
      final res = a * b;
      expect(res.real, 5); // 2*1 - 3*(-1)
      expect(res.imaginary, 1); // 2*(-1) + 3*1
    });

    test('power (De Moivre)', () {
      final a = ComplexNumber(0, 1); // i
      final res = a.power(2); // i^2 = -1
      expect(res.real, closeTo(-1, 0.0001));
      expect(res.imaginary, closeTo(0, 0.0001));
    });

    test('to string formats', () {
      final a = ComplexNumber(3, 4);
      expect(a.toRectangularString(), '3 + 4i');
      expect(a.toPolarString(), '5 ∠ 53.13°');
    });
  });
}
