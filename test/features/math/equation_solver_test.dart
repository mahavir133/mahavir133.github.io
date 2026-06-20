import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/equation_solver/utils/equation_solver.dart';

void main() {
  group('EquationSolver', () {
    test('linear equation', () {
      expect(EquationSolver.solveLinear(2, -4), 'x = 2.0000');
    });

    test('quadratic real roots', () {
      final res = EquationSolver.solveQuadratic(1, -5, 6);
      expect(res.contains('x₁ = 3.0000') || res.contains('x₂ = 3.0000'), true);
      expect(res.contains('x₁ = 2.0000') || res.contains('x₂ = 2.0000'), true);
    });

    test('system of 2 vars', () {
      // 2x + y = 5, x - y = 1 => x=2, y=1
      final res = EquationSolver.solveSystem2(2, 1, 5, 1, -1, 1);
      expect(res, 'x = 2.0000, y = 1.0000');
    });
  });
}
