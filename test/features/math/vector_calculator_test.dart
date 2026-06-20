import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/vector_calculator/utils/vector_calculator.dart';

void main() {
  group('Vector3D', () {
    test('addition', () {
      final a = Vector3D(1, 2, 3);
      final b = Vector3D(4, 5, 6);
      final res = a + b;
      expect(res.x, 5);
      expect(res.y, 7);
      expect(res.z, 9);
    });

    test('dot product', () {
      final a = Vector3D(1, 3, -5);
      final b = Vector3D(4, -2, -1);
      expect(a.dot(b), 3); // 4 - 6 + 5
    });

    test('cross product', () {
      final a = Vector3D(2, 3, 4);
      final b = Vector3D(5, 6, 7);
      final res = a.cross(b);
      expect(res.x, -3);
      expect(res.y, 6);
      expect(res.z, -3);
    });

    test('angle between', () {
      final a = Vector3D(1, 0, 0);
      final b = Vector3D(0, 1, 0);
      expect(a.angleBetween(b), closeTo(90, 0.001));
    });
  });
}
