import 'dart:math';

class CompoundResult {
  final double totalAmount;
  final double totalInterest;

  CompoundResult({
    required this.totalAmount,
    required this.totalInterest,
  });
}

class CompoundInterestCalculator {
  static CompoundResult calculate({
    required double principal,
    required double annualRate,
    required double timeInYears,
    required int compoundingFrequencyPerYear,
  }) {
    if (principal <= 0 || annualRate < 0 || timeInYears <= 0 || compoundingFrequencyPerYear <= 0) {
      return CompoundResult(totalAmount: principal, totalInterest: 0);
    }

    final double r = annualRate / 100;
    final int n = compoundingFrequencyPerYear;
    final double t = timeInYears;

    final double amount = principal * pow(1 + (r / n), n * t);
    
    return CompoundResult(
      totalAmount: amount,
      totalInterest: amount - principal,
    );
  }
}
