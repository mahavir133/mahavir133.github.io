class CustomUnit {
  final String category; // e.g. 'Length', 'Weight/Mass'
  final String unitName; // e.g. 'My Pace'
  final double multiplier; // factor relative to base unit (e.g. 1 unitName = multiplier * baseUnit)
  final double offset; // offset factor, mainly for temperature

  CustomUnit({
    required this.category,
    required this.unitName,
    required this.multiplier,
    this.offset = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'unitName': unitName,
      'multiplier': multiplier,
      'offset': offset,
    };
  }

  factory CustomUnit.fromMap(Map<dynamic, dynamic> map) {
    return CustomUnit(
      category: map['category'] as String,
      unitName: map['unitName'] as String,
      multiplier: (map['multiplier'] as num).toDouble(),
      offset: (map['offset'] as num? ?? 0.0).toDouble(),
    );
  }
}
