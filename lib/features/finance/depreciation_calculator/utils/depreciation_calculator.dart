class DepreciationRow {
  final int year;
  final double depreciationExpense;
  final double accumulatedDepreciation;
  final double bookValue;

  DepreciationRow({
    required this.year,
    required this.depreciationExpense,
    required this.accumulatedDepreciation,
    required this.bookValue,
  });
}

class DepreciationResult {
  final double totalDepreciation;
  final List<DepreciationRow> table;

  DepreciationResult({
    required this.totalDepreciation,
    required this.table,
  });
}

class DepreciationCalculator {
  static DepreciationResult calculateStraightLine({
    required double assetCost,
    required double salvageValue,
    required int usefulLife,
  }) {
    if (assetCost <= 0 || usefulLife <= 0 || salvageValue >= assetCost) {
      return DepreciationResult(totalDepreciation: 0, table: []);
    }

    final double depreciableBase = assetCost - salvageValue;
    final double annualDepreciation = depreciableBase / usefulLife;

    double accumulated = 0;
    double currentBookValue = assetCost;
    List<DepreciationRow> table = [];

    for (int i = 1; i <= usefulLife; i++) {
      accumulated += annualDepreciation;
      currentBookValue -= annualDepreciation;

      table.add(DepreciationRow(
        year: i,
        depreciationExpense: annualDepreciation,
        accumulatedDepreciation: accumulated,
        bookValue: currentBookValue < 0 ? 0 : currentBookValue,
      ));
    }

    return DepreciationResult(
      totalDepreciation: depreciableBase,
      table: table,
    );
  }
}
