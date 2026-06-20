import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/matrix_calculator/utils/matrix_calculator.dart';

void main() {
  group('MatrixCalculator', () {
    test('addition', () {
      final a = [[1.0, 2.0], [3.0, 4.0]];
      final b = [[5.0, 6.0], [7.0, 8.0]];
      final res = MatrixCalculator.add(a, b);
      expect(res, [[6.0, 8.0], [10.0, 12.0]]);
    });

    test('multiplication', () {
      final a = [[1.0, 2.0], [3.0, 4.0]];
      final b = [[2.0, 0.0], [1.0, 2.0]];
      final res = MatrixCalculator.multiply(a, b);
      expect(res, [[4.0, 4.0], [10.0, 8.0]]);
    });

    test('determinant', () {
      final a = [[2.0, -1.0, 0.0], [-1.0, 2.0, -1.0], [0.0, -1.0, 2.0]];
      expect(MatrixCalculator.determinant(a), closeTo(4.0, 0.001));
    });

    test('transpose', () {
      final a = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]];
      final res = MatrixCalculator.transpose(a);
      expect(res, [[1.0, 4.0], [2.0, 5.0], [3.0, 6.0]]);
    });
  });
}
