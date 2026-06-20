class HistoryItem {
  final String id;
  final DateTime timestamp;
  final String module; // 'standard', 'scientific', 'converter', 'currency', 'ocr'
  final String expression;
  final String result;
  final String? note;
  final bool isBookmarked;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.module,
    required this.expression,
    required this.result,
    this.note,
    this.isBookmarked = false,
  });

  HistoryItem copyWith({
    String? id,
    DateTime? timestamp,
    String? module,
    String? expression,
    String? result,
    String? note,
    bool? isBookmarked,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      module: module ?? this.module,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      note: note ?? this.note,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'module': module,
      'expression': expression,
      'result': result,
      'note': note,
      'isBookmarked': isBookmarked,
    };
  }

  factory HistoryItem.fromMap(Map<dynamic, dynamic> map) {
    return HistoryItem(
      id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      module: (map['module'] ?? map['moduleName'] ?? map['category'] ?? 'standard').toString(),
      expression: (map['expression'] ?? map['inputs'] ?? '').toString(),
      result: (map['result'] ?? '').toString(),
      note: map['note'] as String?,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
    );
  }
}
