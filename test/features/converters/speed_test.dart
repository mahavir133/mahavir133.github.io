import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/converters/speed_converter/utils/speed_converter.dart';

void main() {
  group('SpeedConverter', () {
    test('km/h to m/s', () {
      expect(SpeedConverter.convert(36, 'km/h', 'm/s'), closeTo(10.0, 0.001));
    });

    test('mph to km/h', () {
      expect(SpeedConverter.convert(60, 'mph', 'km/h'), closeTo(96.56, 0.01));
    });
  });
}
