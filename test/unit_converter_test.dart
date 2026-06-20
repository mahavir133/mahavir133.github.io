import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omnicalc/core/db/local_db_service.dart';
import 'package:omnicalc/data/repository/unit_converter_repository.dart';

void main() {
  late LocalDbService dbService;
  late UnitConverterRepository repository;

  setUp(() async {
    dbService = LocalDbService();
    await dbService.init('test_hive_dir');
    repository = UnitConverterRepository(dbService);
  });

  tearDown(() async {
    await Hive.close();
    final dir = Directory('test_hive_dir');
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  group('Unit Converter Unit Formulas', () {
    test('Length Conversion (Linear)', () {
      // 1 Meter to Kilometer = 0.001
      expect(repository.convert('Length', 1.0, 'm', 'km'), 0.001);
      // 1 Kilometer to Meter = 1000.0
      expect(repository.convert('Length', 1.0, 'km', 'm'), 1000.0);
      // 1 Inch to Centimeter = 2.54
      expect(repository.convert('Length', 1.0, 'in', 'cm'), 2.54);
    });

    test('Weight/Mass Conversion (Linear)', () {
      // 1 Kilogram to Gram = 1000.0
      expect(repository.convert('Weight/Mass', 1.0, 'kg', 'g'), 1000.0);
      // 1 Pound to Grams = ~453.59
      expect(repository.convert('Weight/Mass', 1.0, 'lb', 'g'), closeTo(453.592, 0.01));
    });

    test('Temperature Conversion (Non-Linear Offsets)', () {
      // 0 Celsius to Fahrenheit = 32.0
      expect(repository.convert('Temperature', 0.0, '°C', '°F'), 32.0);
      // 100 Celsius to Fahrenheit = 212.0
      expect(repository.convert('Temperature', 100.0, '°C', '°F'), 212.0);
      // 0 Celsius to Kelvin = 273.15
      expect(repository.convert('Temperature', 0.0, '°C', 'K'), 273.15);
      // 37 Celsius to Kelvin = 310.15
      expect(repository.convert('Temperature', 37.0, '°C', 'K'), 310.15);
    });

    test('Volume Conversion (Linear)', () {
      // 1 Liter to Milliliter = 1000.0
      expect(repository.convert('Volume', 1.0, 'L', 'mL'), 1000.0);
      // 1 Gallon (US) to Liter = ~3.785
      expect(repository.convert('Volume', 1.0, 'gal (US)', 'L'), closeTo(3.785, 0.01));
    });

    test('Data Storage Conversion (Base 1024)', () {
      // 1 Megabyte to Kilobytes = 1024.0
      expect(repository.convert('Data Storage', 1.0, 'MB', 'KB'), 1024.0);
      // 1 Gigabyte to Megabytes = 1024.0
      expect(repository.convert('Data Storage', 1.0, 'GB', 'MB'), 1024.0);
    });

    test('Fuel Economy Conversion (Inverse)', () {
      // 10 Liters per 100km to Kilometers per Liter = 10.0
      expect(repository.convert('Fuel Economy', 10.0, 'L/100km', 'km/L'), 10.0);
      // 5 Liters per 100km to Kilometers per Liter = 20.0
      expect(repository.convert('Fuel Economy', 5.0, 'L/100km', 'km/L'), 20.0);
    });

    test('Angle Conversion', () {
      // pi Radians to Degrees = 180.0
      expect(repository.convert('Angle', 3.141592653589793, 'rad', '°'), closeTo(180.0, 0.01));
    });
  });
}
