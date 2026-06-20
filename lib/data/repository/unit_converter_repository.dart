import '../../core/db/local_db_service.dart';
import '../../domain/entity/custom_unit.dart';

class ConvertUnit {
  final String name;
  final String symbol;
  final double factor; // factor relative to base unit

  ConvertUnit({required this.name, required this.symbol, required this.factor});
}

class UnitConverterRepository {
  final LocalDbService _dbService;

  UnitConverterRepository(this._dbService);

  // Core base units mapping: category -> units list
  static final Map<String, List<ConvertUnit>> _staticUnits = {
    'Length': [
      ConvertUnit(name: 'Meter', symbol: 'm', factor: 1.0),
      ConvertUnit(name: 'Kilometer', symbol: 'km', factor: 1000.0),
      ConvertUnit(name: 'Centimeter', symbol: 'cm', factor: 0.01),
      ConvertUnit(name: 'Millimeter', symbol: 'mm', factor: 0.001),
      ConvertUnit(name: 'Mile', symbol: 'mi', factor: 1609.344),
      ConvertUnit(name: 'Yard', symbol: 'yd', factor: 0.9144),
      ConvertUnit(name: 'Foot', symbol: 'ft', factor: 0.3048),
      ConvertUnit(name: 'Inch', symbol: 'in', factor: 0.0254),
      ConvertUnit(name: 'Decimeter', symbol: 'dm', factor: 0.1),
      ConvertUnit(name: 'Micrometer', symbol: 'µm', factor: 1e-6),
      ConvertUnit(name: 'Nanometer', symbol: 'nm', factor: 1e-9),
      ConvertUnit(name: 'Nautical Mile', symbol: 'nmi', factor: 1852.0),
      ConvertUnit(name: 'Light Year', symbol: 'ly', factor: 9.4607e15),
    ],
    'Weight/Mass': [
      ConvertUnit(name: 'Kilogram', symbol: 'kg', factor: 1.0),
      ConvertUnit(name: 'Gram', symbol: 'g', factor: 0.001),
      ConvertUnit(name: 'Milligram', symbol: 'mg', factor: 1e-6),
      ConvertUnit(name: 'Pound', symbol: 'lb', factor: 0.45359237),
      ConvertUnit(name: 'Ounce', symbol: 'oz', factor: 0.028349523),
      ConvertUnit(name: 'Stone', symbol: 'st', factor: 6.35029318),
      ConvertUnit(name: 'Tonne (Metric)', symbol: 't', factor: 1000.0),
      ConvertUnit(name: 'Ton (US)', symbol: 'ton_us', factor: 907.18474),
      ConvertUnit(name: 'Carat', symbol: 'ct', factor: 0.0002),
      ConvertUnit(name: 'Microgram', symbol: 'µg', factor: 1e-9),
    ],
    'Temperature': [
      ConvertUnit(name: 'Kelvin', symbol: 'K', factor: 1.0),
      ConvertUnit(name: 'Celsius', symbol: '°C', factor: 1.0),
      ConvertUnit(name: 'Fahrenheit', symbol: '°F', factor: 1.0),
      ConvertUnit(name: 'Rankine', symbol: '°R', factor: 1.0),
    ],
    'Volume': [
      ConvertUnit(name: 'Liter', symbol: 'L', factor: 1.0),
      ConvertUnit(name: 'Milliliter', symbol: 'mL', factor: 0.001),
      ConvertUnit(name: 'Cubic Meter', symbol: 'm³', factor: 1000.0),
      ConvertUnit(name: 'Gallon (US)', symbol: 'gal (US)', factor: 3.78541178),
      ConvertUnit(name: 'Quart (US)', symbol: 'qt (US)', factor: 0.946352946),
      ConvertUnit(name: 'Pint (US)', symbol: 'pt (US)', factor: 0.473176473),
      ConvertUnit(name: 'Cup (US)', symbol: 'cup', factor: 0.236588236),
      ConvertUnit(name: 'Fluid Ounce (US)', symbol: 'fl oz', factor: 0.0295735296),
      ConvertUnit(name: 'Tablespoon (US)', symbol: 'tbsp', factor: 0.0147867648),
      ConvertUnit(name: 'Teaspoon (US)', symbol: 'tsp', factor: 0.00492892159),
      ConvertUnit(name: 'Gallon (UK)', symbol: 'gal (UK)', factor: 4.54609),
    ],
    'Area': [
      ConvertUnit(name: 'Square Meter', symbol: 'm²', factor: 1.0),
      ConvertUnit(name: 'Square Kilometer', symbol: 'km²', factor: 1e6),
      ConvertUnit(name: 'Square Mile', symbol: 'mi²', factor: 2.58998811e6),
      ConvertUnit(name: 'Acre', symbol: 'ac', factor: 4046.85642),
      ConvertUnit(name: 'Hectare', symbol: 'ha', factor: 10000.0),
      ConvertUnit(name: 'Square Yard', symbol: 'yd²', factor: 0.83612736),
      ConvertUnit(name: 'Square Foot', symbol: 'ft²', factor: 0.09290304),
      ConvertUnit(name: 'Square Inch', symbol: 'in²', factor: 0.00064516),
    ],
    'Speed': [
      ConvertUnit(name: 'Meters per Second', symbol: 'm/s', factor: 1.0),
      ConvertUnit(name: 'Kilometers per Hour', symbol: 'km/h', factor: 0.277777778),
      ConvertUnit(name: 'Miles per Hour', symbol: 'mph', factor: 0.44704),
      ConvertUnit(name: 'Knot', symbol: 'kt', factor: 0.514444444),
      ConvertUnit(name: 'Mach', symbol: 'mach', factor: 340.3),
    ],
    'Time': [
      ConvertUnit(name: 'Second', symbol: 's', factor: 1.0),
      ConvertUnit(name: 'Millisecond', symbol: 'ms', factor: 0.001),
      ConvertUnit(name: 'Microsecond', symbol: 'µs', factor: 1e-6),
      ConvertUnit(name: 'Nanosecond', symbol: 'ns', factor: 1e-9),
      ConvertUnit(name: 'Minute', symbol: 'min', factor: 60.0),
      ConvertUnit(name: 'Hour', symbol: 'hr', factor: 3600.0),
      ConvertUnit(name: 'Day', symbol: 'day', factor: 86400.0),
      ConvertUnit(name: 'Week', symbol: 'wk', factor: 604800.0),
      ConvertUnit(name: 'Month', symbol: 'mo', factor: 2.592e6),
      ConvertUnit(name: 'Year', symbol: 'yr', factor: 3.1536e7),
    ],
    'Pressure': [
      ConvertUnit(name: 'Pascal', symbol: 'Pa', factor: 1.0),
      ConvertUnit(name: 'Kilopascal', symbol: 'kPa', factor: 1000.0),
      ConvertUnit(name: 'Bar', symbol: 'bar', factor: 100000.0),
      ConvertUnit(name: 'Millibar', symbol: 'mbar', factor: 100.0),
      ConvertUnit(name: 'PSI', symbol: 'psi', factor: 6894.75729),
      ConvertUnit(name: 'Atmosphere', symbol: 'atm', factor: 101325.0),
      ConvertUnit(name: 'Torr / mmHg', symbol: 'torr', factor: 133.322368),
    ],
    'Energy': [
      ConvertUnit(name: 'Joule', symbol: 'J', factor: 1.0),
      ConvertUnit(name: 'Kilojoule', symbol: 'kJ', factor: 1000.0),
      ConvertUnit(name: 'Calorie', symbol: 'cal', factor: 4.184),
      ConvertUnit(name: 'Kilocalorie', symbol: 'kcal', factor: 4184.0),
      ConvertUnit(name: 'Watt Hour', symbol: 'Wh', factor: 3600.0),
      ConvertUnit(name: 'Kilowatt Hour', symbol: 'kWh', factor: 3.6e6),
      ConvertUnit(name: 'BTU', symbol: 'BTU', factor: 1055.05585),
      ConvertUnit(name: 'Electronvolt', symbol: 'eV', factor: 1.60217663e-19),
    ],
    'Power': [
      ConvertUnit(name: 'Watt', symbol: 'W', factor: 1.0),
      ConvertUnit(name: 'Kilowatt', symbol: 'kW', factor: 1000.0),
      ConvertUnit(name: 'Megawatt', symbol: 'MW', factor: 1e6),
      ConvertUnit(name: 'Horsepower (Imp)', symbol: 'hp', factor: 745.699872),
      ConvertUnit(name: 'Horsepower (Metric)', symbol: 'hk', factor: 735.49875),
      ConvertUnit(name: 'BTU/hr', symbol: 'BTU/h', factor: 0.293071),
    ],
    'Data Storage': [
      ConvertUnit(name: 'Byte', symbol: 'B', factor: 1.0),
      ConvertUnit(name: 'Bit', symbol: 'bit', factor: 0.125),
      ConvertUnit(name: 'Kilobyte', symbol: 'KB', factor: 1024.0),
      ConvertUnit(name: 'Megabyte', symbol: 'MB', factor: 1048576.0),
      ConvertUnit(name: 'Gigabyte', symbol: 'GB', factor: 1073741824.0),
      ConvertUnit(name: 'Terabyte', symbol: 'TB', factor: 1.0995116e12),
      ConvertUnit(name: 'Petabyte', symbol: 'PB', factor: 1.1258999e15),
    ],
    'Fuel Economy': [
      ConvertUnit(name: 'Kilometers per Liter', symbol: 'km/L', factor: 1.0),
      ConvertUnit(name: 'Miles per Gallon (US)', symbol: 'mpg (US)', factor: 1.0),
      ConvertUnit(name: 'Miles per Gallon (UK)', symbol: 'mpg (UK)', factor: 1.0),
      ConvertUnit(name: 'Liters per 100km', symbol: 'L/100km', factor: 1.0),
    ],
    'Angle': [
      ConvertUnit(name: 'Radian', symbol: 'rad', factor: 1.0),
      ConvertUnit(name: 'Degree', symbol: '°', factor: 0.017453292519943295),
      ConvertUnit(name: 'Gradian', symbol: 'gon', factor: 0.015707963267948967),
    ],
  };

  /// Returns all categories
  List<String> getCategories() => _staticUnits.keys.toList();

  /// Gets the full units list for a category, combining static units and user custom units.
  List<ConvertUnit> getUnits(String category) {
    final list = List<ConvertUnit>.from(_staticUnits[category] ?? []);

    // Fetch custom units from Hive
    final customBox = _dbService.customUnitsBox;
    final customs = customBox.values
        .map((v) => CustomUnit.fromMap(Map<String, dynamic>.from(v as Map)))
        .where((u) => u.category == category);

    for (final cu in customs) {
      list.add(ConvertUnit(name: cu.unitName, symbol: cu.unitName.substring(0, 2), factor: cu.multiplier));
    }

    return list;
  }

  /// Adds a custom unit for a category.
  Future<void> addCustomUnit(CustomUnit unit) async {
    final customBox = _dbService.customUnitsBox;
    final key = '${unit.category}_${unit.unitName}';
    await customBox.put(key, unit.toMap());
  }

  /// Bidirectional conversion logic
  double convert(String category, double value, String fromSymbol, String toSymbol) {
    if (fromSymbol == toSymbol) return value;

    final units = getUnits(category);
    final fromUnit = units.firstWhere((u) => u.symbol == fromSymbol);
    final toUnit = units.firstWhere((u) => u.symbol == toSymbol);

    // 1. Temperature conversion (non-linear offset calculation)
    if (category == 'Temperature') {
      double kelvin;
      // Convert from source to Kelvin (base unit)
      switch (fromSymbol) {
        case '°C':
          kelvin = value + 273.15;
          break;
        case '°F':
          kelvin = (value - 32) * 5 / 9 + 273.15;
          break;
        case '°R':
          kelvin = value * 5 / 9;
          break;
        case 'K':
        default:
          kelvin = value;
          break;
      }

      // Convert from Kelvin to target
      switch (toSymbol) {
        case '°C':
          return kelvin - 273.15;
        case '°F':
          return (kelvin - 273.15) * 9 / 5 + 32;
        case '°R':
          return kelvin * 9 / 5;
        case 'K':
        default:
          return kelvin;
      }
    }

    // 2. Fuel economy conversion (inverse relationships)
    if (category == 'Fuel Economy') {
      // Convert source to km/L (base)
      double kmL;
      switch (fromSymbol) {
        case 'mpg (US)':
          kmL = value * 0.425143707;
          break;
        case 'mpg (UK)':
          kmL = value * 0.35400619;
          break;
        case 'L/100km':
          if (value == 0) return 0.0;
          kmL = 100.0 / value;
          break;
        case 'km/L':
        default:
          kmL = value;
          break;
      }

      // Convert km/L to target
      switch (toSymbol) {
        case 'mpg (US)':
          return kmL / 0.425143707;
        case 'mpg (UK)':
          return kmL / 0.35400619;
        case 'L/100km':
          if (kmL == 0) return 0.0;
          return 100.0 / kmL;
        case 'km/L':
        default:
          return kmL;
      }
    }

    // 3. Standard linear conversions
    // Value in base units = value * fromUnit.factor
    // Value in target units = value in base units / toUnit.factor
    final baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  // Favorite/pinned conversions CRUD
  List<Map<String, String>> getFavorites() {
    final box = _dbService.favoritesBox;
    final list = box.get('pinned_pairs', defaultValue: <dynamic>[]) as List;
    return list.map((v) => Map<String, String>.from(v as Map)).toList();
  }

  Future<void> pinFavorite(String category, String fromUnit, String toUnit) async {
    final box = _dbService.favoritesBox;
    final list = getFavorites();

    // Check if already pinned
    final exists = list.any((map) =>
        map['category'] == category && map['from'] == fromUnit && map['to'] == toUnit);

    if (!exists) {
      list.add({
        'category': category,
        'from': fromUnit,
        'to': toUnit,
      });
      await box.put('pinned_pairs', list);
    }
  }

  Future<void> unpinFavorite(String category, String fromUnit, String toUnit) async {
    final box = _dbService.favoritesBox;
    final list = getFavorites();
    list.removeWhere((map) =>
        map['category'] == category && map['from'] == fromUnit && map['to'] == toUnit);
    await box.put('pinned_pairs', list);
  }
}
