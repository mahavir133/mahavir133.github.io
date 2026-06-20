class CurrencyAlert {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final double threshold;
  final bool isAbove; // true to alert if rate > threshold, false for rate < threshold
  final bool isActive;

  CurrencyAlert({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.threshold,
    required this.isAbove,
    this.isActive = true,
  });

  CurrencyAlert copyWith({
    String? id,
    String? baseCurrency,
    String? targetCurrency,
    double? threshold,
    bool? isAbove,
    bool? isActive,
  }) {
    return CurrencyAlert(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      threshold: threshold ?? this.threshold,
      isAbove: isAbove ?? this.isAbove,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'threshold': threshold,
      'isAbove': isAbove,
      'isActive': isActive,
    };
  }

  factory CurrencyAlert.fromMap(Map<dynamic, dynamic> map) {
    return CurrencyAlert(
      id: map['id'] as String,
      baseCurrency: map['baseCurrency'] as String,
      targetCurrency: map['targetCurrency'] as String,
      threshold: (map['threshold'] as num).toDouble(),
      isAbove: map['isAbove'] as bool,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
