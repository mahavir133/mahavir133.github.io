import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:omnicalc/data/repository/currency_repository.dart';
import 'package:omnicalc/core/db/local_db_service.dart';
import 'package:omnicalc/presentation/provider/providers.dart';
import 'package:omnicalc/presentation/screen/app_shell.dart';

void main() {
  setUpAll(() async {
    final dir = Directory('test_shell_hive');
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
    Hive.init('test_shell_hive');
  });

  tearDownAll(() async {
    await Hive.close();
    final dir = Directory('test_shell_hive');
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  testWidgets('AppShell renders Navigation Bar and switches tabs', (WidgetTester tester) async {
    // Set realistic mobile screen size to prevent keys/elements from clipping out of the viewport
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final dbService = LocalDbService();
    await tester.runAsync(() async {
      await dbService.init('test_shell_hive');
    });
    final mockCurrencyRepo = FakeCurrencyRepository(dbService);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDbServiceProvider.overrideWithValue(dbService),
          currencyRepositoryProvider.overrideWithValue(mockCurrencyRepo),
        ],
        child: const MaterialApp(
          home: AppShell(),
        ),
      ),
    );

    // Verify Navigation bar destinations are rendered
    expect(find.text('Home'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}

class FakeCurrencyRepository extends CurrencyRepository {
  FakeCurrencyRepository(LocalDbService dbService)
      : super(dbService, Dio(), initNotifications: false);

  @override
  Future<Map<String, dynamic>> fetchRates() async {
    return {
      'rates': {
        'USD': 1.0,
        'EUR': 0.9,
        'GBP': 0.8,
        'INR': 83.0,
        'JPY': 150.0,
      },
      'timestamp': DateTime.now(),
      'fromCache': true,
    };
  }
}
