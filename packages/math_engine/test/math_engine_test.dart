import 'package:flutter_test/flutter_test.dart';
import 'package:math_engine/math_engine.dart';
import 'dart:math' as math;

void main() {
  final engine = MathEngine();

  group('Core Arithmetic and Precedence', () {
    test('Addition & Subtraction', () {
      expect(engine.evaluate('1 + 2 - 3'), 0.0);
      expect(engine.evaluate('10 - 2 + 5'), 13.0);
    });

    test('Operator Precedence', () {
      expect(engine.evaluate('2 + 3 * 4'), 14.0);
      expect(engine.evaluate('(2 + 3) * 4'), 20.0);
      expect(engine.evaluate('10 - 4 / 2'), 8.0);
      expect(engine.evaluate('2^3 * 2 + 1'), 17.0); // 8 * 2 + 1
    });

    test('Modulo', () {
      expect(engine.evaluate('10 % 3'), 1.0);
      expect(engine.evaluate('15 % 5'), 0.0);
    });

    test('Decimal & Negative parsing', () {
      expect(engine.evaluate('-5.5 + 10'), 4.5);
      expect(engine.evaluate('2 * -3'), -6.0);
    });

    test('Implicit Multiplication', () {
      expect(engine.evaluate('2pi'), closeTo(2 * math.pi, 1e-9));
      expect(engine.evaluate('2(3 + 4)'), 14.0);
      expect(engine.evaluate('(2+3)(4+5)'), 45.0);
      expect(engine.evaluate('3x', variables: {'x': 10.0}), 30.0);
    });
  });

  group('Scientific Mode Functions & Constants', () {
    test('Constants', () {
      expect(engine.evaluate('pi'), closeTo(math.pi, 1e-9));
      expect(engine.evaluate('e'), closeTo(math.e, 1e-9));
      expect(engine.evaluate('N_A'), 6.02214076e23);
      expect(engine.evaluate('c'), 299792458.0);
      expect(engine.evaluate('h'), 6.62607015e-34);
    });

    test('Trigonometry (Radians)', () {
      expect(engine.evaluate('sin(0)'), 0.0);
      expect(engine.evaluate('cos(0)'), 1.0);
      expect(engine.evaluate('sin(pi / 2)'), closeTo(1.0, 1e-9));
      expect(engine.evaluate('cos(pi)'), closeTo(-1.0, 1e-9));
      expect(engine.evaluate('tan(0)'), 0.0);
    });

    test('Trigonometry (Degrees)', () {
      expect(engine.evaluate('sin(90)', isDegreeMode: true), 1.0);
      expect(engine.evaluate('cos(180)', isDegreeMode: true), -1.0);
      expect(engine.evaluate('tan(45)', isDegreeMode: true), closeTo(1.0, 1e-9));
    });

    test('Inverse Trigonometry', () {
      expect(engine.evaluate('asin(1)', isDegreeMode: true), 90.0);
      expect(engine.evaluate('acos(-1)', isDegreeMode: true), 180.0);
      expect(engine.evaluate('atan(1)', isDegreeMode: true), 45.0);
    });

    test('Logarithms', () {
      expect(engine.evaluate('ln(e)'), 1.0);
      expect(engine.evaluate('log(100)'), 2.0);
      expect(engine.evaluate('logBase(2, 8)'), 3.0);
    });

    test('Roots & Powers', () {
      expect(engine.evaluate('sqrt(16)'), 4.0);
      expect(engine.evaluate('cbrt(-8)'), -2.0);
      expect(engine.evaluate('cbrt(27)'), 3.0);
      expect(engine.evaluate('16^(1/4)'), 2.0);
    });

    test('Factorial, Permutations & Combinations', () {
      expect(engine.evaluate('5!'), 120.0);
      expect(engine.evaluate('0!'), 1.0);
      expect(engine.evaluate('nPr(5, 2)'), 20.0);
      expect(engine.evaluate('nCr(5, 2)'), 10.0);
      expect(engine.evaluate('abs(-9.9)'), 9.9);
    });
  });

  group('Bitwise and Programmer Mode', () {
    test('Hex, Octal, Binary Parsing', () {
      expect(engine.evaluate('0xFF'), 255.0);
      expect(engine.evaluate('0b1010'), 10.0);
      expect(engine.evaluate('0o77'), 63.0);
    });

    test('Bitwise Operations', () {
      expect(engine.evaluate('5 & 3', isProgrammerMode: true), 1.0);
      expect(engine.evaluate('5 | 3', isProgrammerMode: true), 7.0);
      expect(engine.evaluate('5 ^ 3', isProgrammerMode: true), 6.0);
      expect(engine.evaluate('~5', isProgrammerMode: true), -6.0);
      expect(engine.evaluate('1 << 3', isProgrammerMode: true), 8.0);
      expect(engine.evaluate('8 >> 2', isProgrammerMode: true), 2.0);
    });

    test('Base Conversions', () {
      expect(engine.convertBase('255', NumberBase.dec, NumberBase.hex), '0xFF');
      expect(engine.convertBase('0xFF', NumberBase.hex, NumberBase.bin), '0b11111111');
      expect(engine.convertBase('0b1010', NumberBase.bin, NumberBase.dec), '10');
      expect(engine.convertBase('0o77', NumberBase.oct, NumberBase.dec), '63');
    });
  });

  group('Algebraic Solver (Step-by-Step)', () {
    test('Solve simple linear equations', () {
      final steps = engine.solve('3x + 5 = 20', variable: 'x');
      expect(steps.isNotEmpty, true);
      // Final step should be x = 5
      expect(steps.last.equation, 'x = 5');
    });

    test('Solve with variables on both sides', () {
      final steps = engine.solve('5x - 4 = 2x + 8', variable: 'x');
      expect(steps.isNotEmpty, true);
      expect(steps.last.equation, 'x = 4');
    });

    test('Solve simple division equations', () {
      final steps = engine.solve('x / 2 = 10', variable: 'x');
      expect(steps.isNotEmpty, true);
      expect(steps.last.equation, 'x = 20');
    });
  });

  group('Error Handling', () {
    test('Divide by zero', () {
      expect(() => engine.evaluate('5 / 0'), throwsException);
    });

    test('Modulo by zero', () {
      expect(() => engine.evaluate('5 % 0'), throwsException);
    });

    test('Malformed expressions', () {
      expect(() => engine.evaluate('2 + * 3'), throwsException);
      expect(() => engine.evaluate('((2 + 3)'), throwsException);
    });
  });
}
