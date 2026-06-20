class TaxResult {
  final double netAmount;
  final double taxAmount;
  final double grossAmount;

  TaxResult({
    required this.netAmount,
    required this.taxAmount,
    required this.grossAmount,
  });
}

class TaxCalculator {
  static TaxResult calculate({
    required double amount,
    required double taxRate,
    required bool isTaxInclusive,
  }) {
    if (amount <= 0 || taxRate < 0) {
      return TaxResult(netAmount: 0, taxAmount: 0, grossAmount: 0);
    }

    if (isTaxInclusive) {
      // Amount is Gross. We need Net and Tax.
      // Gross = Net * (1 + rate/100)
      // Net = Gross / (1 + rate/100)
      final netAmount = amount / (1 + taxRate / 100);
      final taxAmount = amount - netAmount;
      return TaxResult(
        netAmount: netAmount,
        taxAmount: taxAmount,
        grossAmount: amount,
      );
    } else {
      // Amount is Net. We need Gross and Tax.
      final taxAmount = amount * (taxRate / 100);
      final grossAmount = amount + taxAmount;
      return TaxResult(
        netAmount: amount,
        taxAmount: taxAmount,
        grossAmount: grossAmount,
      );
    }
  }
}
