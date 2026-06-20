import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/features/converters/temperature_converter/utils/temperature_converter.dart';

void main() {
  group('TemperatureConverter', () {
    test('Celsius to Fahrenheit', () {
      final res = TemperatureConverter.convert(0, 'Celsius (°C)', 'Fahrenheit (°F)');
      expect(res.value, 32);
      expect(res.formula, contains('°F = (0.0 × 9/5) + 32'));
    });

    test('Fahrenheit to Kelvin', () {
      final res = TemperatureConverter.convert(32, 'Fahrenheit (°F)', 'Kelvin (K)');
      expect(res.value, 273.15);
      expect(res.formula, contains('C = (32.0 - 32) × 5/9'));
      expect(res.formula, contains('K = 0.00 + 273.15'));
    });
  });
}
