import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/calculus_toolkit/utils/calculus_toolkit.dart';

void main() {
  group('CalculusToolkit', () {
    test('evaluate', () {
      expect(CalculusToolkit.evaluate('x^2', 3), 9);
      expect(CalculusToolkit.evaluate('sin(x)', 0), 0);
    });

    test('differentiation', () {
      // d/dx x^2 at x=3 is 6
      final res = CalculusToolkit.differentiate('x^2', 3);
      expect(res.value, closeTo(6.0, 0.001));
    });

    test('integration', () {
      // integral of x^2 from 0 to 3 is x^3/3 = 27/3 = 9
      final res = CalculusToolkit.integrate('x^2', 0, 3);
      expect(res.value, closeTo(9.0, 0.001));
    });

    test('limits', () {
      // lim x->2 of x^2 is 4
      final res = CalculusToolkit.limit('x^2', 2);
      expect(res.value, closeTo(4.0, 0.001));
    });
  });
}
