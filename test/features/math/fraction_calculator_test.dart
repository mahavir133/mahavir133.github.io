import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/fraction_calculator/utils/fraction_calculator.dart';

void main() {
  group('Fraction', () {
    test('addition', () {
      final a = Fraction(1, 2);
      final b = Fraction(1, 3);
      final result = a + b;
      expect(result.numerator, 5);
      expect(result.denominator, 6);
    });

    test('subtraction', () {
      final a = Fraction(1, 2);
      final b = Fraction(1, 3);
      final result = a - b;
      expect(result.numerator, 1);
      expect(result.denominator, 6);
    });

    test('multiplication', () {
      final a = Fraction(2, 3);
      final b = Fraction(3, 4);
      final result = a * b;
      expect(result.numerator, 1);
      expect(result.denominator, 2);
    });

    test('division', () {
      final a = Fraction(2, 3);
      final b = Fraction(3, 4);
      final result = a / b;
      expect(result.numerator, 8);
      expect(result.denominator, 9);
    });

    test('to mixed number', () {
      final a = Fraction(10, 3);
      expect(a.toMixedNumber(), '3 1/3');
    });
  });
}
