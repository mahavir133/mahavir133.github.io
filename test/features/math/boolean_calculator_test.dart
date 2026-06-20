import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/boolean_calculator/utils/boolean_algebra.dart';

void main() {
  group('BooleanAlgebra', () {
    test('truth table generation', () {
      final res = BooleanAlgebra.generateTruthTable('A AND B', ['A', 'B']);
      expect(res.last, '1 | 1 | 1'); // Both true -> true
      expect(res[2], '0 | 0 | 0');
    });

    test('complex evaluation', () {
      final res = BooleanAlgebra.generateTruthTable('NOT(A OR B)', ['A', 'B']);
      // NOR gate
      expect(res[2], '0 | 0 | 1');
      expect(res.last, '1 | 1 | 0');
    });
  });
}
