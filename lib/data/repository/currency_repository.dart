import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/db/local_db_service.dart';
import '../../domain/entity/currency_alert.dart';

class CurrencyRepository {
  final LocalDbService _dbService;
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  CurrencyRepository(this._dbService, this._dio, {bool initNotifications = true}) {
    if (initNotifications) {
      _initNotifications();
    }
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  /// Fetches rates from the API, falling back to local cache if offline.
  /// Returns a map with 'rates' (Map<String, double>) and 'timestamp' (DateTime).
  Future<Map<String, dynamic>> fetchRates() async {
    final cacheBox = _dbService.currencyCacheBox;
    final cachedData = cacheBox.get('latest_rates');

    final now = DateTime.now();

    if (cachedData != null) {
      final cachedMap = Map<String, dynamic>.from(cachedData as Map);
      final cacheTime = DateTime.parse(cachedMap['timestamp'] as String);
      final rates = Map<String, double>.from(
        (cachedMap['rates'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      );

      // Cache is valid for 1 hour
      if (now.difference(cacheTime).inHours < 1) {
        return {'rates': rates, 'timestamp': cacheTime, 'fromCache': true};
      }
    }

    // Attempt to fetch fresh rates
    try {
      final response = await _dio.get(
        'https://open.er-api.com/v6/latest/USD',
        options: Options(receiveTimeout: const Duration(seconds: 5), sendTimeout: const Duration(seconds: 5)),
      );

      if (response.statusCode == 200 && response.data != null) {
        final ratesRaw = response.data['rates'] as Map;
        final rates = ratesRaw.map((k, v) => MapEntry(k as String, (v as num).toDouble()));

        final cacheEntry = {
          'rates': rates,
          'timestamp': now.toIso8601String(),
        };
        await cacheBox.put('latest_rates', cacheEntry);

        // Check alerts
        _checkAlerts(rates);

        return {'rates': rates, 'timestamp': now, 'fromCache': false};
      }
    } catch (e) {
      // Failed to fetch, try returning cached data even if expired
      if (cachedData != null) {
        final cachedMap = Map<String, dynamic>.from(cachedData as Map);
        final cacheTime = DateTime.parse(cachedMap['timestamp'] as String);
        final rates = Map<String, double>.from(
          (cachedMap['rates'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
        );
        return {'rates': rates, 'timestamp': cacheTime, 'fromCache': true, 'offline': true};
      }
      rethrow;
    }

    throw Exception('No exchange rate data available');
  }

  /// Generates deterministic historical rate data based on a base rate, seeded pseudo-randomly.
  List<Map<String, dynamic>> getHistoricalRates(
    String base,
    String target,
    int days,
    Map<String, double> currentRates,
  ) {
    final list = <Map<String, dynamic>>[];
    final now = DateTime.now();

    final baseToUsd = currentRates[base] ?? 1.0;
    final targetToUsd = currentRates[target] ?? 1.0;
    final currentRate = targetToUsd / baseToUsd;

    // Seed Random with a hash of (base, target) so the chart is stable for the day
    final seed = (base.hashCode ^ target.hashCode ^ now.day ^ now.month ^ now.year).abs();
    final rand = Random(seed);

    double activeRate = currentRate;
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      list.add({
        'date': date,
        'rate': activeRate,
      });

      // Walk backward with a small variance (between -1.5% and +1.5% daily fluctuation)
      final changePercent = (rand.nextDouble() - 0.5) * 0.03;
      activeRate = activeRate * (1 - changePercent);
    }

    return list.reversed.toList();
  }

  // Alerts CRUD
  List<CurrencyAlert> getAlerts() {
    final box = _dbService.alertsBox;
    return box.values.map((v) {
      final map = Map<String, dynamic>.from(v as Map);
      return CurrencyAlert.fromMap(map);
    }).toList();
  }

  Future<void> saveAlert(CurrencyAlert alert) async {
    await _dbService.alertsBox.put(alert.id, alert.toMap());
  }

  Future<void> deleteAlert(String id) async {
    await _dbService.alertsBox.delete(id);
  }

  // Watchlist CRUD
  List<String> getWatchlist() {
    final box = _dbService.watchlistBox;
    final list = box.get('watchlist_keys', defaultValue: <dynamic>[]) as List;
    return list.cast<String>();
  }

  Future<void> saveWatchlist(List<String> list) async {
    await _dbService.watchlistBox.put('watchlist_keys', list);
  }

  Future<void> _checkAlerts(Map<String, double> rates) async {
    final alerts = getAlerts();
    for (final alert in alerts) {
      if (!alert.isActive) continue;

      final baseVal = rates[alert.baseCurrency] ?? 1.0;
      final targetVal = rates[alert.targetCurrency] ?? 1.0;
      final rate = targetVal / baseVal;

      bool triggered = false;
      if (alert.isAbove && rate >= alert.threshold) {
        triggered = true;
      } else if (!alert.isAbove && rate <= alert.threshold) {
        triggered = true;
      }

      if (triggered) {
        // Trigger notification
        await _showNotification(alert, rate);
        // Deactivate alert so it doesn't spam
        await saveAlert(alert.copyWith(isActive: false));
      }
    }
  }

  Future<void> _showNotification(CurrencyAlert alert, double currentRate) async {
    const androidDetails = AndroidNotificationDetails(
      'currency_alerts',
      'Currency Rate Alerts',
      channelDescription: 'Notifications for currency exchange rate alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final currentStr = currentRate.toStringAsFixed(4);
    final threshStr = alert.threshold.toStringAsFixed(4);
    final dir = alert.isAbove ? 'risen above' : 'fallen below';

    await _notificationsPlugin.show(
      alert.id.hashCode,
      'Currency Rate Alert!',
      '${alert.baseCurrency}/${alert.targetCurrency} has $dir $threshStr (Current: $currentStr)',
      details,
    );
  }

  // Helper properties
  static final Map<String, String> currencySymbols = {
    'USD': 'USD', 'EUR': 'EUR', 'GBP': 'GBP', 'INR': 'INR', 'JPY': 'JPY',
    'AUD': 'AUD', 'CAD': 'CAD', 'CHF': 'CHF', 'CNY': 'CNY', 'NZD': 'NZD',
    'AED': 'AED', 'ARS': 'ARS', 'BRL': 'BRL', 'CLP': 'CLP', 'COP': 'COP',
    'CZK': 'CZK', 'DKK': 'DKK', 'EGP': 'EGP', 'HKD': 'HKD', 'HUF': 'HUF',
    'IDR': 'IDR', 'ILS': 'ILS', 'KRW': 'KRW', 'MXN': 'MXN', 'MYR': 'MYR',
    'NOK': 'NOK', 'PHP': 'PHP', 'PLN': 'PLN', 'RON': 'RON', 'RUB': 'RUB',
    'SAR': 'SAR', 'SEK': 'SEK', 'SGD': 'SGD', 'THB': 'THB', 'TRY': 'TRY',
    'TWD': 'TWD', 'UAH': 'UAH', 'VES': 'VES', 'VND': 'VND', 'ZAR': 'ZAR',
  };

  static final Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'INR': 'Indian Rupee',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'NZD': 'New Zealand Dollar',
    'AED': 'UAE Dirham',
    'AFN': 'Afghan Afghani',
    'ALL': 'Albanian Lek',
    'AMD': 'Armenian Dram',
    'ANG': 'Neth. Antillean Guilder',
    'AOA': 'Angolan Kwanza',
    'ARS': 'Argentine Peso',
    'AWG': 'Aruban Florin',
    'AZN': 'Azerbaijani Manat',
    'BAM': 'Bosnia-Herzegovina Mark',
    'BBD': 'Barbadian Dollar',
    'BDT': 'Bangladeshi Taka',
    'BGN': 'Bulgarian Lev',
    'BHD': 'Bahraini Dinar',
    'BIF': 'Burundian Franc',
    'BMD': 'Bermudian Dollar',
    'BND': 'Brunei Dollar',
    'BOB': 'Bolivian Boliviano',
    'BRL': 'Brazilian Real',
    'BSD': 'Bahamian Dollar',
    'BTN': 'Bhutanese Ngultrum',
    'BWP': 'Botswana Pula',
    'BYN': 'Belarusian Ruble',
    'BZD': 'Belize Dollar',
    'CDF': 'Congolese Franc',
    'CLP': 'Chilean Peso',
    'COP': 'Colombian Peso',
    'CRC': 'Costa Rican Colón',
    'CUP': 'Cuban Peso',
    'CVE': 'Cape Verdean Escudo',
    'CZK': 'Czech Koruna',
    'DJF': 'Djiboutian Franc',
    'DKK': 'Danish Krone',
    'DOP': 'Dominican Peso',
    'DZD': 'Algerian Dinar',
    'EGP': 'Egyptian Pound',
    'ERN': 'Eritrean Nakfa',
    'ETB': 'Ethiopian Birr',
    'FJD': 'Fijian Dollar',
    'FKP': 'Falkland Islands Pound',
    'FOK': 'Faroese Króna',
    'GEL': 'Georgian Lari',
    'GGP': 'Guernsey Pound',
    'GHS': 'Ghanaian Cedi',
    'GIP': 'Gibraltar Pound',
    'GMD': 'Gambian Dalasi',
    'GNF': 'Guinean Franc',
    'GTQ': 'Guatemalan Quetzal',
    'GYD': 'Guyanese Dollar',
    'HKD': 'Hong Kong Dollar',
    'HNL': 'Honduran Lempira',
    'HRK': 'Croatian Kuna',
    'HTG': 'Haitian Gourde',
    'HUF': 'Hungarian Forint',
    'IDR': 'Indonesian Rupiah',
    'ILS': 'Israeli New Shekel',
    'IMP': 'Isle of Man Pound',
    'IQD': 'Iraqi Dinar',
    'IRR': 'Iranian Rial',
    'ISK': 'Icelandic Króna',
    'JEP': 'Jersey Pound',
    'JMD': 'Jamaican Dollar',
    'JOD': 'Jordanian Dinar',
    'KES': 'Kenyan Shilling',
    'KGS': 'Kyrgystani Som',
    'KHR': 'Cambodian Riel',
    'KID': 'Kiribati Dollar',
    'KMF': 'Comorian Franc',
    'KRW': 'South Korean Won',
    'KWD': 'Kuwaiti Dinar',
    'KYD': 'Cayman Islands Dollar',
    'KZT': 'Kazakhstani Tenge',
    'LAK': 'Laotian Kip',
    'LBP': 'Lebanese Pound',
    'LKR': 'Sri Lankan Rupee',
    'LRD': 'Liberian Dollar',
    'LSL': 'Lesotho Loti',
    'LYD': 'Libyan Dinar',
    'MAD': 'Moroccan Dirham',
    'MDL': 'Moldovan Leu',
    'MGA': 'Malagasy Ariary',
    'MKD': 'Macedonian Denar',
    'MMK': 'Myanmar Kyat',
    'MNT': 'Mongolian Tughrik',
    'MOP': 'Macanese Pataca',
    'MRU': 'Mauritanian Ouguiya',
    'MUR': 'Mauritian Rupee',
    'MVR': 'Maldivian Rufiyaa',
    'MWK': 'Malawian Kwacha',
    'MXN': 'Mexican Peso',
    'MYR': 'Malaysian Ringgit',
    'MZN': 'Mozambican Metical',
    'NAD': 'Namibian Dollar',
    'NGN': 'Nigerian Naira',
    'NIO': 'Nicaraguan Córdoba',
    'NOK': 'Norwegian Krone',
    'NPR': 'Nepalese Rupee',
    'OMR': 'Omani Rial',
    'PAB': 'Panamanian Balboa',
    'PEN': 'Peruvian Sol',
    'PGK': 'Papua New Guinean Kina',
    'PHP': 'Philippine Peso',
    'PKR': 'Pakistani Rupee',
    'PLN': 'Polish Złoty',
    'PYG': 'Paraguayan Guaraní',
    'QAR': 'Qatari Riyal',
    'RON': 'Romanian Leu',
    'RSD': 'Serbian Dinar',
    'RUB': 'Russian Ruble',
    'RWF': 'Rwandan Franc',
    'SAR': 'Saudi Riyal',
    'SBD': 'Solomon Islands Dollar',
    'SCR': 'Seychellois Rupee',
    'SDG': 'Sudanese Pound',
    'SEK': 'Swedish Krona',
    'SGD': 'Singapore Dollar',
    'SHP': 'St. Helena Pound',
    'SLE': 'Sierra Leonean Leone',
    'SOS': 'Somali Shilling',
    'SRD': 'Surinamese Dollar',
    'SSP': 'South Sudanese Pound',
    'STN': 'São Tomé Dobra',
    'SYP': 'Syrian Pound',
    'SZL': 'Swazi Lilangeni',
    'THB': 'Thai Baht',
    'TJS': 'Tajikistani Somoni',
    'TMT': 'Turkmenistani Manat',
    'TND': 'Tunisian Dinar',
    'TOP': 'Tongan Paʻanga',
    'TRY': 'Turkish Lira',
    'TTD': 'Trinidad & Tobago Dollar',
    'TWD': 'New Taiwan Dollar',
    'TZS': 'Tanzanian Shilling',
    'UAH': 'Ukrainian Hryvnia',
    'UGX': 'Ugandan Shilling',
    'UYU': 'Uruguayan Peso',
    'UZS': 'Uzbekistani Soʻm',
    'VES': 'Venezuelan Bolívar',
    'VND': 'Vietnamese Đồng',
    'VUV': 'Vanuatu Vatu',
    'WST': 'Samoan Tālā',
    'XAF': 'Central African CFA Franc',
    'XCD': 'East Caribbean Dollar',
    'XOF': 'West African CFA Franc',
    'XPF': 'CFP Franc',
    'YER': 'Yemeni Rial',
    'ZAR': 'South African Rand',
    'ZMW': 'Zambian Kwacha',
    'ZWL': 'Zimbabwean Dollar',
  };

  static String currencyToEmoji(String currencyCode) {
    final map = {
      'USD': 'US', 'EUR': 'EU', 'GBP': 'GB', 'INR': 'IN', 'JPY': 'JP',
      'AUD': 'AU', 'CAD': 'CA', 'CHF': 'CH', 'CNY': 'CN', 'NZD': 'NZ',
      'AED': 'AE', 'AFN': 'AF', 'ALL': 'AL', 'AMD': 'AM', 'ANG': 'CW',
      'AOA': 'AO', 'ARS': 'AR', 'AWG': 'AW', 'AZN': 'AZ', 'BAM': 'BA',
      'BBD': 'BB', 'BDT': 'BD', 'BGN': 'BG', 'BHD': 'BH', 'BIF': 'BI',
      'BMD': 'BM', 'BND': 'BN', 'BOB': 'BO', 'BRL': 'BR', 'BSD': 'BS',
      'BTN': 'BT', 'BWP': 'BW', 'BYN': 'BY', 'BZD': 'BZ', 'CDF': 'CD',
      'CLP': 'CL', 'COP': 'CO', 'CRC': 'CR', 'CUP': 'CU', 'CVE': 'CV',
      'CZK': 'CZ', 'DJF': 'DJ', 'DKK': 'DK', 'DOP': 'DO', 'DZD': 'DZ',
      'EGP': 'EG', 'ERN': 'ER', 'ETB': 'ET', 'FJD': 'FJ', 'FKP': 'FK',
      'FOK': 'FO', 'GEL': 'GE', 'GGP': 'GG', 'GHS': 'GH', 'GIP': 'GI',
      'GMD': 'GM', 'GNF': 'GN', 'GTQ': 'GT', 'GYD': 'GY', 'HKD': 'HK',
      'HNL': 'HN', 'HRK': 'HR', 'HTG': 'HT', 'HUF': 'HU', 'IDR': 'ID',
      'ILS': 'IL', 'IMP': 'IM', 'IQD': 'IQ', 'IRR': 'IR', 'ISK': 'IS',
      'JEP': 'JE', 'JMD': 'JM', 'JOD': 'JO', 'KES': 'KE', 'KGS': 'KG',
      'KHR': 'KH', 'KID': 'KI', 'KMF': 'KM', 'KRW': 'KR', 'KWD': 'KW',
      'KYD': 'KY', 'KZT': 'KZ', 'LAK': 'LA', 'LBP': 'LB', 'LKR': 'LK',
      'LRD': 'LR', 'LSL': 'LS', 'LYD': 'LY', 'MAD': 'MA', 'MDL': 'MD',
      'MGA': 'MG', 'MKD': 'MK', 'MMK': 'MM', 'MNT': 'MN', 'MOP': 'MO',
      'MRU': 'MR', 'MUR': 'MU', 'MVR': 'MV', 'MWK': 'MW', 'MXN': 'MX',
      'MYR': 'MY', 'MZN': 'MZ', 'NAD': 'NA', 'NGN': 'NG', 'NIO': 'NI',
      'NOK': 'NO', 'NPR': 'NP', 'OMR': 'OM', 'PAB': 'PA', 'PEN': 'PE',
      'PGK': 'PG', 'PHP': 'PH', 'PKR': 'PK', 'PLN': 'PL', 'PYG': 'PY',
      'QAR': 'QA', 'RON': 'RO', 'RSD': 'RS', 'RUB': 'RU', 'RWF': 'RW',
      'SAR': 'SA', 'SBD': 'SB', 'SCR': 'SC', 'SDG': 'SD', 'SEK': 'SE',
      'SGD': 'SG', 'SHP': 'SH', 'SLE': 'SL', 'SLL': 'SL', 'SOS': 'SO',
      'SRD': 'SR', 'SSP': 'SS', 'STN': 'ST', 'SYP': 'SY', 'SZL': 'SZ',
      'THB': 'TH', 'TJS': 'TJ', 'TMT': 'TM', 'TND': 'TN', 'TOP': 'TO',
      'TRY': 'TR', 'TTD': 'TT', 'TVD': 'TV', 'TWD': 'TW', 'TZS': 'TZ',
      'UAH': 'UA', 'UGX': 'UG', 'UYU': 'UY', 'UZS': 'UZ', 'VES': 'VE',
      'VND': 'VN', 'VUV': 'VU', 'WST': 'WS', 'XAF': 'CM', 'XCD': 'AG',
      'XDR': 'EU', 'XOF': 'SN', 'XPF': 'PF', 'YER': 'YE', 'ZAR': 'ZA',
      'ZMW': 'ZM', 'ZWL': 'ZW',
    };
    final country = map[currencyCode] ?? '';
    if (country.isEmpty) return '🏳️';
    return country.toUpperCase().replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
        );
  }
}
