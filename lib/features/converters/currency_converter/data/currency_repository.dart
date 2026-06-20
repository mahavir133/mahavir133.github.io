import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/db/local_db_service.dart';
import '../../../../presentation/provider/providers.dart';

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return CurrencyRepository(dbService.currencyCacheBox);
});

class CurrencyRepository {
  final Box _cacheBox;
  final Dio _dio = Dio();

  static const String _apiUrl = 'https://open.er-api.com/v6/latest/USD';
  static const String _cacheKey = 'rates_cache';
  static const String _timestampKey = 'rates_timestamp';

  CurrencyRepository(this._cacheBox);

  Future<Map<String, double>> getRates() async {
    try {
      // 1. Try to fetch from API
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['rates'];

        // Convert dynamic map to Map<String, double>
        final Map<String, double> rates = {};
        data.forEach((key, value) {
          rates[key] = (value as num).toDouble();
        });

        // 2. Cache it
        await _cacheBox.put(_cacheKey, rates);
        await _cacheBox.put(_timestampKey, DateTime.now().toIso8601String());

        return rates;
      } else {
        throw Exception("Failed to load rates");
      }
    } catch (e) {
      // 3. Fallback to cache
      final cachedRates = _cacheBox.get(_cacheKey);
      if (cachedRates != null) {
        return Map<String, double>.from(cachedRates);
      } else {
        throw Exception("No internet and no cached data available.");
      }
    }
  }

  DateTime? getLastUpdate() {
    final timestamp = _cacheBox.get(_timestampKey);
    if (timestamp != null) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }
}
