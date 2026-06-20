import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/currency_repository.dart';

final currencyRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(currencyRepositoryProvider);
  return repo.getRates();
});

final currencyUpdateDateProvider = Provider<DateTime?>((ref) {
  // Listen to the future provider to rebuild when it finishes, but read from repo.
  ref.watch(currencyRatesProvider);
  final repo = ref.watch(currencyRepositoryProvider);
  return repo.getLastUpdate();
});
