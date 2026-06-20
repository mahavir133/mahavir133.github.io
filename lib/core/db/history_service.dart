import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/provider/providers.dart';

class HistoryEntry {
  final String id;
  final String moduleName;
  final String category;
  final String inputs;
  final String result;
  final DateTime timestamp;

  HistoryEntry({
    required this.id,
    required this.moduleName,
    required this.category,
    required this.inputs,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleName': moduleName,
      'category': category,
      'inputs': inputs,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String,
      moduleName: map['moduleName'] as String,
      category: map['category'] as String,
      inputs: map['inputs'] as String,
      result: map['result'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class HistoryService {
  final Ref _ref;
  
  HistoryService(this._ref);

  Future<void> logCalculation({
    required String moduleName,
    required String category,
    required String inputs,
    required String result,
  }) async {
    final dbService = _ref.read(localDbServiceProvider);
    final box = dbService.historyBox;
    
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moduleName: moduleName,
      category: category,
      inputs: inputs,
      result: result,
      timestamp: DateTime.now(),
    );

    // Save to Hive
    await box.add(entry.toMap());
  }

  List<HistoryEntry> getHistory() {
    final dbService = _ref.read(localDbServiceProvider);
    final box = dbService.historyBox;
    
    final entries = box.values.map((e) {
      if (e is Map) {
        return HistoryEntry.fromMap(e);
      }
      return null;
    }).whereType<HistoryEntry>().toList();
    
    // Sort descending by timestamp
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
}

final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService(ref);
});
