class TipResult {
  final double tipAmount;
  final double totalBill;
  final double perPersonAmount;

  TipResult({
    required this.tipAmount,
    required this.totalBill,
    required this.perPersonAmount,
  });
}

class TipCalculator {
  static TipResult calculate({
    required double billAmount,
    required double tipPercentage,
    required int numberOfPeople,
  }) {
    if (billAmount <= 0 || numberOfPeople <= 0 || tipPercentage < 0) {
      return TipResult(tipAmount: 0, totalBill: 0, perPersonAmount: 0);
    }

    final tipAmount = billAmount * (tipPercentage / 100);
    final totalBill = billAmount + tipAmount;
    final perPersonAmount = totalBill / numberOfPeople;

    return TipResult(
      tipAmount: tipAmount,
      totalBill: totalBill,
      perPersonAmount: perPersonAmount,
    );
  }
}
