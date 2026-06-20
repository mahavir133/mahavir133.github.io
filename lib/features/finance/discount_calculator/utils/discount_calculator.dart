class DiscountResult {
  final double finalPrice;
  final double savings;

  DiscountResult({
    required this.finalPrice,
    required this.savings,
  });
}

class DiscountCalculator {
  static DiscountResult calculate({
    required double originalPrice,
    required double discount1,
    required double discount2,
  }) {
    if (originalPrice <= 0) {
      return DiscountResult(finalPrice: 0, savings: 0);
    }

    // Apply first discount
    final d1Amount = originalPrice * (discount1 / 100);
    final priceAfterD1 = originalPrice - d1Amount;

    // Apply second discount (chain discount)
    final d2Amount = priceAfterD1 * (discount2 / 100);
    final finalPrice = priceAfterD1 - d2Amount;

    return DiscountResult(
      finalPrice: finalPrice,
      savings: originalPrice - finalPrice,
    );
  }
}
