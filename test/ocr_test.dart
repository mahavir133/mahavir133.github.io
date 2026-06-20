import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omnicalc/core/db/local_db_service.dart';
import 'package:omnicalc/presentation/provider/providers.dart';

void main() {
  setUpAll(() async {
    final dir = Directory('test_ocr_hive');
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
    Hive.init('test_ocr_hive');
  });

  tearDownAll(() async {
    await Hive.close();
    final dir = Directory('test_ocr_hive');
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  test('OCR Notifier parses arithmetic and algebraic formulas correctly', () async {
    final dbService = LocalDbService();
    await dbService.init('test_ocr_hive');

    final container = ProviderContainer(
      overrides: [
        localDbServiceProvider.overrideWithValue(dbService),
      ],
    );

    addTearDown(() {
      container.dispose();
    });

    final ocrNotifier = container.read(ocrProvider.notifier);

    // 1. Test arithmetic OCR solver
    ocrNotifier.setParsedText('2 + 3 * 4');
    ocrNotifier.solve();

    var state = container.read(ocrProvider);
    expect(state.status, OcrStatus.success);
    expect(state.solutionResult, '14');
    expect(state.steps.length, 1);
    expect(state.steps.first.equation, '2 + 3 * 4 = 14');

    // 2. Test algebraic equation solver
    ocrNotifier.setParsedText('3x + 5 = 20');
    ocrNotifier.solve();

    state = container.read(ocrProvider);
    expect(state.status, OcrStatus.success);
    expect(state.solutionResult, 'x = 5');
    expect(state.steps.isNotEmpty, true);
    expect(state.steps.last.equation, 'x = 5');
  });
}
