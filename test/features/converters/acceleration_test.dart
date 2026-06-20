import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/converters/acceleration_converter/utils/acceleration_converter.dart';

void main() {
  group('AccelerationConverter', () {
    test('m/s2 to g-force', () {
      expect(AccelerationConverter.convert(9.80665, 'm/s²', 'g-force (g)'), closeTo(1.0, 0.001));
    });

    test('ft/s2 to m/s2', () {
      expect(AccelerationConverter.convert(1, 'ft/s²', 'm/s²'), closeTo(0.3048, 0.001));
    });
  });
}
