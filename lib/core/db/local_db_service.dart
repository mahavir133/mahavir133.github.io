import 'package:hive_flutter/hive_flutter.dart';

class LocalDbService {
  late Box _historyBox;
  late Box _currencyCacheBox;
  late Box _favoritesBox;
  late Box _customUnitsBox;
  late Box _watchlistBox;
  late Box _alertsBox;
  late Box _settingsBox;

  Future<void> init([String? testPath]) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    _historyBox = await Hive.openBox('history');
    _currencyCacheBox = await Hive.openBox('currency_cache');
    _favoritesBox = await Hive.openBox('converter_favorites');
    _customUnitsBox = await Hive.openBox('custom_units');
    _watchlistBox = await Hive.openBox('watchlist');
    _alertsBox = await Hive.openBox('currency_alerts');
    _settingsBox = await Hive.openBox('settings');
  }

  // History box
  Box get historyBox => _historyBox;

  // Currency rates cache box
  Box get currencyCacheBox => _currencyCacheBox;

  // Conversion favorites box
  Box get favoritesBox => _favoritesBox;

  // Custom units box
  Box get customUnitsBox => _customUnitsBox;

  // Currency watchlist box
  Box get watchlistBox => _watchlistBox;

  // Currency alerts box
  Box get alertsBox => _alertsBox;

  // Settings box
  Box get settingsBox => _settingsBox;

  /// Utility to clear all databases
  Future<void> clearAll() async {
    await _historyBox.clear();
    await _currencyCacheBox.clear();
    await _favoritesBox.clear();
    await _customUnitsBox.clear();
    await _watchlistBox.clear();
    await _alertsBox.clear();
  }
}
