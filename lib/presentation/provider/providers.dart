import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:math_engine/math_engine.dart';
import '../../core/db/local_db_service.dart';
import '../../domain/entity/history_item.dart';
import '../../domain/entity/custom_unit.dart';
import '../../domain/entity/currency_alert.dart';
import '../../data/repository/history_repository.dart';
import '../../data/repository/currency_repository.dart';
import '../../data/repository/unit_converter_repository.dart';

// ----------------------------------------------------
// Dependency Injection Providers
// ----------------------------------------------------

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  throw UnimplementedError('Initialize localDbServiceProvider in main.dart first');
});

final dioProvider = Provider<Dio>((ref) => Dio());

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(localDbServiceProvider);
  return HistoryRepository(db);
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  final db = ref.watch(localDbServiceProvider);
  final dio = ref.watch(dioProvider);
  return CurrencyRepository(db, dio);
});

final unitConverterRepositoryProvider = Provider<UnitConverterRepository>((ref) {
  final db = ref.watch(localDbServiceProvider);
  return UnitConverterRepository(db);
});

final mathEngineProvider = Provider<MathEngine>((ref) => MathEngine());

// ----------------------------------------------------
// Calculator State & Notifier
// ----------------------------------------------------

class CalculatorState {
  final String expression;
  final String result;
  final bool isDegreeMode;
  final bool isScientific;
  final NumberBase programmerBase;
  final String? errorMessage;

  CalculatorState({
    this.expression = '',
    this.result = '0',
    this.isDegreeMode = false,
    this.isScientific = false,
    this.programmerBase = NumberBase.dec,
    this.errorMessage,
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    bool? isDegreeMode,
    bool? isScientific,
    NumberBase? programmerBase,
    String? errorMessage,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      isDegreeMode: isDegreeMode ?? this.isDegreeMode,
      isScientific: isScientific ?? this.isScientific,
      programmerBase: programmerBase ?? this.programmerBase,
      errorMessage: errorMessage,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final Ref _ref;

  CalculatorNotifier(this._ref) : super(CalculatorState());

  void clear() {
    state = CalculatorState(
      isDegreeMode: state.isDegreeMode,
      isScientific: state.isScientific,
      programmerBase: state.programmerBase,
    );
  }

  void backspace() {
    if (state.expression.isEmpty) return;
    state = state.copyWith(
      expression: state.expression.substring(0, state.expression.length - 1),
    );
  }

  void append(String char) {
    // If starting fresh with a previous result, chain it if appending an operator
    final ops = ['+', '-', '*', '/', '%', '^', '&', '|', '<<', '>>'];
    if (state.expression.isEmpty && ops.contains(char) && state.result != '0' && state.result != 'Error') {
      state = state.copyWith(expression: state.result + char);
      return;
    }
    state = state.copyWith(expression: state.expression + char);
  }

  void toggleDegreeMode() {
    state = state.copyWith(isDegreeMode: !state.isDegreeMode);
  }

  void toggleScientificMode() {
    state = state.copyWith(isScientific: !state.isScientific);
  }

  void setProgrammerBase(NumberBase base) {
    if (state.programmerBase == base) return;

    // Convert result to new base
    final engine = _ref.read(mathEngineProvider);
    String convertedResult = state.result;
    if (state.result != '0' && state.result != 'Error') {
      try {
        convertedResult = engine.convertBase(state.result, state.programmerBase, base);
      } catch (_) {
        convertedResult = '0';
      }
    }
    state = state.copyWith(programmerBase: base, result: convertedResult);
  }

  void evaluate() {
    if (state.expression.isEmpty) return;

    final engine = _ref.read(mathEngineProvider);
    final historyRepo = _ref.read(historyRepositoryProvider);

    try {
      final isProg = state.programmerBase != NumberBase.dec;
      final val = engine.evaluate(
        state.expression,
        isDegreeMode: state.isDegreeMode,
        isProgrammerMode: isProg,
      );

      final formattedRes = isProg
          ? engine.convertBase(val.toInt().toString(), NumberBase.dec, state.programmerBase)
          : _formatDouble(val);

      // Save to Hive history
      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        module: state.isScientific ? 'scientific' : (isProg ? 'programmer' : 'standard'),
        expression: state.expression,
        result: formattedRes,
      );
      historyRepo.saveItem(historyItem);
      _ref.read(historyProvider.notifier).refresh();

      state = state.copyWith(result: formattedRes);
    } catch (e) {
      state = state.copyWith(result: 'Error', errorMessage: e.toString());
    }
  }

  void loadFromHistory(String expr) {
    state = state.copyWith(expression: expr);
  }

  String _formatDouble(double val) {
    if (val.isInfinite) return val.isNegative ? '-Infinity' : 'Infinity';
    if (val.isNaN) return 'NaN';
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    String s = val.toString();
    if (s.contains('e') || s.contains('E')) return s;

    final parts = s.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    if (intPart.length + decPart.length > 15) {
      final maxDec = 15 - intPart.length;
      if (maxDec <= 0) {
        return val.toStringAsExponential(9);
      } else {
        s = val.toStringAsFixed(maxDec);
      }
    }

    if (s.contains('.')) {
      var end = s.length - 1;
      while (end >= 0 && s[end] == '0') {
        end--;
      }
      if (end >= 0 && s[end] == '.') {
        end--;
      }
      s = s.substring(0, end + 1);
    }
    return s;
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier(ref);
});

// ----------------------------------------------------
// Unit Converter State & Notifier
// ----------------------------------------------------

class ConverterState {
  final String selectedCategory;
  final List<ConvertUnit> availableUnits;
  final String fromUnit;
  final String toUnit;
  final String fromValue;
  final String toValue;
  final List<Map<String, String>> pinnedFavorites;

  ConverterState({
    required this.selectedCategory,
    required this.availableUnits,
    required this.fromUnit,
    required this.toUnit,
    this.fromValue = '',
    this.toValue = '',
    this.pinnedFavorites = const [],
  });

  ConverterState copyWith({
    String? selectedCategory,
    List<ConvertUnit>? availableUnits,
    String? fromUnit,
    String? toUnit,
    String? fromValue,
    String? toValue,
    List<Map<String, String>>? pinnedFavorites,
  }) {
    return ConverterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      availableUnits: availableUnits ?? this.availableUnits,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      fromValue: fromValue ?? this.fromValue,
      toValue: toValue ?? this.toValue,
      pinnedFavorites: pinnedFavorites ?? this.pinnedFavorites,
    );
  }
}

class ConverterNotifier extends StateNotifier<ConverterState> {
  final Ref _ref;

  ConverterNotifier(this._ref)
      : super(ConverterState(
          selectedCategory: 'Length',
          availableUnits: [],
          fromUnit: 'm',
          toUnit: 'km',
        )) {
    changeCategory('Length');
  }

  void changeCategory(String category) {
    final repo = _ref.read(unitConverterRepositoryProvider);
    final units = repo.getUnits(category);
    final favorites = repo.getFavorites();

    state = ConverterState(
      selectedCategory: category,
      availableUnits: units,
      fromUnit: units.isNotEmpty ? units[0].symbol : '',
      toUnit: units.length > 1 ? units[1].symbol : '',
      pinnedFavorites: favorites,
    );
  }

  void updateFromValue(String val) {
    if (val.isEmpty) {
      state = state.copyWith(fromValue: '', toValue: '');
      return;
    }
    final d = double.tryParse(val);
    if (d == null) return;

    final repo = _ref.read(unitConverterRepositoryProvider);
    final res = repo.convert(state.selectedCategory, d, state.fromUnit, state.toUnit);
    state = state.copyWith(fromValue: val, toValue: _format(res));
  }

  void updateToValue(String val) {
    if (val.isEmpty) {
      state = state.copyWith(fromValue: '', toValue: '');
      return;
    }
    final d = double.tryParse(val);
    if (d == null) return;

    final repo = _ref.read(unitConverterRepositoryProvider);
    final res = repo.convert(state.selectedCategory, d, state.toUnit, state.fromUnit);
    state = state.copyWith(toValue: val, fromValue: _format(res));
  }

  void setFromUnit(String symbol) {
    state = state.copyWith(fromUnit: symbol);
    updateFromValue(state.fromValue);
  }

  void setToUnit(String symbol) {
    state = state.copyWith(toUnit: symbol);
    updateFromValue(state.fromValue);
  }

  void toggleFavorite() {
    final repo = _ref.read(unitConverterRepositoryProvider);
    final isPinned = state.pinnedFavorites.any((f) =>
        f['category'] == state.selectedCategory &&
        f['from'] == state.fromUnit &&
        f['to'] == state.toUnit);

    if (isPinned) {
      repo.unpinFavorite(state.selectedCategory, state.fromUnit, state.toUnit);
    } else {
      repo.pinFavorite(state.selectedCategory, state.fromUnit, state.toUnit);
    }
    state = state.copyWith(pinnedFavorites: repo.getFavorites());
  }

  Future<void> addCustom(String unitName, double multiplier) async {
    final repo = _ref.read(unitConverterRepositoryProvider);
    final cu = CustomUnit(
      category: state.selectedCategory,
      unitName: unitName,
      multiplier: multiplier,
    );
    await repo.addCustomUnit(cu);
    // Refresh units list
    final units = repo.getUnits(state.selectedCategory);
    state = state.copyWith(availableUnits: units);
  }

  String _format(double val) {
    if (val % 1 == 0) return val.toInt().toString();
    final fixed = val.toStringAsFixed(6);
    var end = fixed.length - 1;
    while (end >= 0 && fixed[end] == '0') {
      end--;
    }
    if (end >= 0 && fixed[end] == '.') {
      end--;
    }
    return fixed.substring(0, end + 1);
  }
}

final converterProvider = StateNotifierProvider<ConverterNotifier, ConverterState>((ref) {
  return ConverterNotifier(ref);
});

// ----------------------------------------------------
// Currency Tracker State & Notifier
// ----------------------------------------------------

class CurrencyState {
  final bool isLoading;
  final Map<String, double> rates;
  final String baseCurrency;
  final List<String> targetCurrencies;
  final double baseAmount;
  final DateTime? cacheTimestamp;
  final bool isOffline;
  final List<CurrencyAlert> alerts;
  final List<String> watchlist;
  final String? error;

  CurrencyState({
    this.isLoading = false,
    this.rates = const {},
    this.baseCurrency = 'USD',
    this.targetCurrencies = const ['EUR', 'GBP', 'INR', 'JPY'],
    this.baseAmount = 1.0,
    this.cacheTimestamp,
    this.isOffline = false,
    this.alerts = const [],
    this.watchlist = const [],
    this.error,
  });

  CurrencyState copyWith({
    bool? isLoading,
    Map<String, double>? rates,
    String? baseCurrency,
    List<String>? targetCurrencies,
    double? baseAmount,
    DateTime? cacheTimestamp,
    bool? isOffline,
    List<CurrencyAlert>? alerts,
    List<String>? watchlist,
    String? error,
  }) {
    return CurrencyState(
      isLoading: isLoading ?? this.isLoading,
      rates: rates ?? this.rates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrencies: targetCurrencies ?? this.targetCurrencies,
      baseAmount: baseAmount ?? this.baseAmount,
      cacheTimestamp: cacheTimestamp ?? this.cacheTimestamp,
      isOffline: isOffline ?? this.isOffline,
      alerts: alerts ?? this.alerts,
      watchlist: watchlist ?? this.watchlist,
      error: error,
    );
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final Ref _ref;

  CurrencyNotifier(this._ref) : super(CurrencyState()) {
    refreshRates();
  }

  Future<void> refreshRates() async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(currencyRepositoryProvider);

    try {
      final result = await repo.fetchRates();
      final rates = result['rates'] as Map<String, double>;
      final timestamp = result['timestamp'] as DateTime;
      final isOffline = result['offline'] as bool? ?? false;

      final savedAlerts = repo.getAlerts();
      final watchlist = repo.getWatchlist();

      state = state.copyWith(
        isLoading: false,
        rates: rates,
        cacheTimestamp: timestamp,
        isOffline: isOffline,
        alerts: savedAlerts,
        watchlist: watchlist.isEmpty ? ['EUR', 'GBP', 'INR', 'JPY'] : watchlist,
        targetCurrencies: watchlist.isEmpty ? ['EUR', 'GBP', 'INR', 'JPY'] : watchlist,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateBaseAmount(double amount) {
    state = state.copyWith(baseAmount: amount);
  }

  void changeBaseCurrency(String currency) {
    state = state.copyWith(baseCurrency: currency);
  }

  Future<void> addToWatchlist(String currency) async {
    if (state.watchlist.contains(currency)) return;
    final updated = [...state.watchlist, currency];
    final repo = _ref.read(currencyRepositoryProvider);
    await repo.saveWatchlist(updated);
    state = state.copyWith(watchlist: updated, targetCurrencies: updated);
  }

  Future<void> removeFromWatchlist(String currency) async {
    final updated = state.watchlist.where((c) => c != currency).toList();
    final repo = _ref.read(currencyRepositoryProvider);
    await repo.saveWatchlist(updated);
    state = state.copyWith(watchlist: updated, targetCurrencies: updated);
  }

  Future<void> addAlert(String target, double threshold, bool isAbove) async {
    final repo = _ref.read(currencyRepositoryProvider);
    final alert = CurrencyAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baseCurrency: state.baseCurrency,
      targetCurrency: target,
      threshold: threshold,
      isAbove: isAbove,
    );
    await repo.saveAlert(alert);
    state = state.copyWith(alerts: repo.getAlerts());
  }

  Future<void> removeAlert(String id) async {
    final repo = _ref.read(currencyRepositoryProvider);
    await repo.deleteAlert(id);
    state = state.copyWith(alerts: repo.getAlerts());
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  return CurrencyNotifier(ref);
});

// ----------------------------------------------------
// History State & Notifier
// ----------------------------------------------------

class HistoryState {
  final List<HistoryItem> items;
  final String query;
  final String? filterModule;

  HistoryState({
    this.items = const [],
    this.query = '',
    this.filterModule,
  });

  HistoryState copyWith({
    List<HistoryItem>? items,
    String? query,
    String? filterModule,
  }) {
    return HistoryState(
      items: items ?? this.items,
      query: query ?? this.query,
      filterModule: filterModule,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(HistoryState()) {
    refresh();
  }

  void refresh() {
    final repo = _ref.read(historyRepositoryProvider);
    final list = repo.getHistory();
    state = state.copyWith(items: list);
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
  }

  void setFilterModule(String? module) {
    state = state.copyWith(filterModule: module);
  }

  Future<void> deleteItem(String id) async {
    final repo = _ref.read(historyRepositoryProvider);
    await repo.deleteItem(id);
    refresh();
  }

  Future<void> toggleBookmark(String id) async {
    final repo = _ref.read(historyRepositoryProvider);
    await repo.toggleBookmark(id);
    refresh();
  }

  Future<void> clearAll() async {
    final repo = _ref.read(historyRepositoryProvider);
    await repo.clearAll();
    refresh();
  }

  Future<void> addNote(String id, String note) async {
    final repo = _ref.read(historyRepositoryProvider);
    final item = state.items.firstWhere((i) => i.id == id);
    final updated = item.copyWith(note: note.isEmpty ? null : note);
    await repo.updateItem(updated);
    refresh();
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});

// ----------------------------------------------------
// OCR Math Solver State & Notifier
// ----------------------------------------------------

enum OcrStatus { idle, loading, success, error }

class OcrState {
  final OcrStatus status;
  final String parsedText;
  final String? solutionResult;
  final List<SolverStep> steps;
  final String? errorMessage;

  OcrState({
    this.status = OcrStatus.idle,
    this.parsedText = '',
    this.solutionResult,
    this.steps = const [],
    this.errorMessage,
  });

  OcrState copyWith({
    OcrStatus? status,
    String? parsedText,
    String? solutionResult,
    List<SolverStep>? steps,
    String? errorMessage,
  }) {
    return OcrState(
      status: status ?? this.status,
      parsedText: parsedText ?? this.parsedText,
      solutionResult: solutionResult ?? this.solutionResult,
      steps: steps ?? this.steps,
      errorMessage: errorMessage,
    );
  }
}

class OcrNotifier extends StateNotifier<OcrState> {
  final Ref _ref;

  OcrNotifier(this._ref) : super(OcrState());

  void setParsedText(String text) {
    state = state.copyWith(parsedText: text);
  }

  void solve() {
    if (state.parsedText.isEmpty) return;

    state = state.copyWith(status: OcrStatus.loading, errorMessage: null);
    final engine = _ref.read(mathEngineProvider);
    final historyRepo = _ref.read(historyRepositoryProvider);

    try {
      final input = state.parsedText.trim();

      // If it contains an '=', solve it as an algebraic equation
      if (input.contains('=')) {
        final steps = engine.solve(input, variable: 'x');
        final finalVal = steps.last.equation.split('=').last.trim();

        // Save OCR solved calculation in History
        final historyItem = HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          module: 'ocr',
          expression: input,
          result: finalVal,
          note: 'AI OCR Algebraic Solver',
        );
        historyRepo.saveItem(historyItem);
        _ref.read(historyProvider.notifier).refresh();

        state = state.copyWith(
          status: OcrStatus.success,
          solutionResult: steps.last.equation,
          steps: steps,
        );
      } else {
        // Just evaluate the expression
        final resultVal = engine.evaluate(input);
        final formattedResult = _formatDouble(resultVal);

        final historyItem = HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          module: 'ocr',
          expression: input,
          result: formattedResult,
          note: 'AI OCR Arithmetic Scanner',
        );
        historyRepo.saveItem(historyItem);
        _ref.read(historyProvider.notifier).refresh();

        state = state.copyWith(
          status: OcrStatus.success,
          solutionResult: formattedResult,
          steps: [SolverStep('Evaluate Arithmetic Expression', '$input = $formattedResult')],
        );
      }
    } catch (e) {
      state = state.copyWith(status: OcrStatus.error, errorMessage: e.toString());
    }
  }

  String _formatDouble(double val) {
    if (val.isInfinite) return val.isNegative ? '-Infinity' : 'Infinity';
    if (val.isNaN) return 'NaN';
    if (val % 1 == 0) return val.toInt().toString();
    final fixed = val.toStringAsFixed(6);
    var end = fixed.length - 1;
    while (end >= 0 && fixed[end] == '0') {
      end--;
    }
    if (end >= 0 && fixed[end] == '.') {
      end--;
    }
    return fixed.substring(0, end + 1);
  }
}

final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(ref);
});

// ----------------------------------------------------
// Theme State & Notifier
// ----------------------------------------------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  static const _key = 'theme_mode';

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final db = _ref.read(localDbServiceProvider);
    final val = db.settingsBox.get(_key, defaultValue: 'system') as String;
    switch (val) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final db = _ref.read(localDbServiceProvider);
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    
    await db.settingsBox.put(_key, val);
    state = mode;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

// ----------------------------------------------------
// Premium Status & In-App Purchase Providers
// ----------------------------------------------------

class PremiumStatusNotifier extends StateNotifier<bool> {
  final Ref _ref;
  static const _key = 'is_ad_free';

  PremiumStatusNotifier(this._ref) : super(false) {
    _loadStatus();
  }

  void _loadStatus() {
    final db = _ref.read(localDbServiceProvider);
    state = db.settingsBox.get(_key, defaultValue: false) as bool;
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    final db = _ref.read(localDbServiceProvider);
    await db.settingsBox.put(_key, isPremium);
    state = isPremium;
  }
}

final premiumStatusProvider = StateNotifierProvider<PremiumStatusNotifier, bool>((ref) {
  return PremiumStatusNotifier(ref);
});

class IapManager {
  final Ref _ref;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];
  bool isStoreAvailable = false;

  IapManager(this._ref);

  void initialize() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    final purchaseUpdatedStream = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdatedStream.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('IAP purchaseStream error: $error');
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Purchase pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.productID == 'remove_ads') {
            await _ref.read(premiumStatusProvider.notifier).setPremiumStatus(true);
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> checkStoreAvailability() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return false;
    }
    try {
      isStoreAvailable = await InAppPurchase.instance.isAvailable();
      return isStoreAvailable;
    } catch (_) {
      isStoreAvailable = false;
      return false;
    }
  }

  Future<List<ProductDetails>> fetchProducts() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return [];
    }
    
    final bool available = await checkStoreAvailability();
    if (!available) {
      return [];
    }

    const Set<String> kIds = <String>{'remove_ads'};
    try {
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(kIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }
      products = response.productDetails;
      return products;
    } catch (e) {
      debugPrint('Error querying product details: $e');
      return [];
    }
  }

  Future<void> buyRemoveAds(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }
}

final iapManagerProvider = Provider<IapManager>((ref) {
  final manager = IapManager(ref);
  manager.initialize();
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});
