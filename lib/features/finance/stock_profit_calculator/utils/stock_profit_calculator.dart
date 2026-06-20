class StockProfitResult {
  final double totalInvested;
  final double totalRevenue;
  final double profitOrLoss;
  final double roi;
  final bool isProfit;

  StockProfitResult({
    required this.totalInvested,
    required this.totalRevenue,
    required this.profitOrLoss,
    required this.roi,
    required this.isProfit,
  });
}

class StockProfitCalculator {
  static StockProfitResult calculate({
    required double buyPrice,
    required double sellPrice,
    required double quantity,
    required double buyFees,
    required double sellFees,
  }) {
    if (quantity <= 0 || buyPrice < 0 || sellPrice < 0) {
      return StockProfitResult(
        totalInvested: 0,
        totalRevenue: 0,
        profitOrLoss: 0,
        roi: 0,
        isProfit: true,
      );
    }

    final totalInvested = (buyPrice * quantity) + buyFees;
    final totalRevenue = (sellPrice * quantity) - sellFees;
    final diff = totalRevenue - totalInvested;
    final isProfit = diff >= 0;
    
    final roi = totalInvested > 0 ? (diff / totalInvested) * 100 : 0.0;

    return StockProfitResult(
      totalInvested: totalInvested,
      totalRevenue: totalRevenue,
      profitOrLoss: diff.abs(),
      roi: roi,
      isProfit: isProfit,
    );
  }
}
