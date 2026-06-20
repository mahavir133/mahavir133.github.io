import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/math/base_converter/utils/base_converter.dart';

void main() {
  group('BaseConverter', () {
    test('converts from decimal correctly', () {
      final result = BaseConverter.convert(value: '255', fromBase: 10, toCustomBase: 36);

      expect(result.binary, '11111111');
      expect(result.hex, 'FF');
      expect(result.octal, '377');
    });

    test('converts from hex correctly', () {
      final result = BaseConverter.convert(value: 'FF', fromBase: 16, toCustomBase: 2);

      expect(result.decimal, '255');
    });

    test('handles bitwise OR', () {
      // 1010 OR 0101 = 1111 (in base 2) -> A OR 5 = F (in base 16)
      final res = BaseConverter.bitwiseOp('A', '5', 16, 'OR');
      expect(res, 'F');
    });
  });
}
