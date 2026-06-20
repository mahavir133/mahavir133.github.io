class ProfitLossResult {
  final double profitOrLoss;
  final bool isProfit;
  final double marginPercentage;
  final double markupPercentage;

  ProfitLossResult({
    required this.profitOrLoss,
    required this.isProfit,
    required this.marginPercentage,
    required this.markupPercentage,
  });
}

class ProfitLossCalculator {
  static ProfitLossResult calculate({
    required double costPrice,
    required double sellingPrice,
  }) {
    if (costPrice <= 0) {
      return ProfitLossResult(
        profitOrLoss: 0,
        isProfit: true,
        marginPercentage: 0,
        markupPercentage: 0,
      );
    }

    final diff = sellingPrice - costPrice;
    final isProfit = diff >= 0;
    final absDiff = diff.abs();

    final margin = (absDiff / sellingPrice) * 100;
    final markup = (absDiff / costPrice) * 100;

    return ProfitLossResult(
      profitOrLoss: absDiff,
      isProfit: isProfit,
      marginPercentage: sellingPrice == 0 ? 0 : margin,
      markupPercentage: markup,
    );
  }
}
