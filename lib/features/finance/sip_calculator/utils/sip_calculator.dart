import 'dart:math';

class SipResult {
  final double investedAmount;
  final double estimatedReturns;
  final double totalValue;
  final List<SipYearlyRow> yearlyTable;

  SipResult({
    required this.investedAmount,
    required this.estimatedReturns,
    required this.totalValue,
    required this.yearlyTable,
  });
}

class SipYearlyRow {
  final int year;
  final double invested;
  final double futureValue;

  SipYearlyRow({
    required this.year,
    required this.invested,
    required this.futureValue,
  });
}

class SipCalculator {
  static SipResult calculateSip({
    required double monthlyInvestment,
    required double annualReturnRate,
    required int tenureYears,
  }) {
    if (monthlyInvestment <= 0 || tenureYears <= 0) {
      return SipResult(investedAmount: 0, estimatedReturns: 0, totalValue: 0, yearlyTable: []);
    }

    if (annualReturnRate <= 0) {
      final invested = monthlyInvestment * 12 * tenureYears;
      return SipResult(
        investedAmount: invested,
        estimatedReturns: 0,
        totalValue: invested,
        yearlyTable: List.generate(tenureYears, (index) {
          final amount = monthlyInvestment * 12 * (index + 1);
          return SipYearlyRow(year: index + 1, invested: amount, futureValue: amount);
        }),
      );
    }

    final double i = annualReturnRate / 12 / 100;
    final int months = tenureYears * 12;
    
    double fv = monthlyInvestment * ((pow(1 + i, months) - 1) / i) * (1 + i);
    double invested = monthlyInvestment * months;

    List<SipYearlyRow> yearlyTable = [];
    for (int y = 1; y <= tenureYears; y++) {
      int m = y * 12;
      double yearlyFv = monthlyInvestment * ((pow(1 + i, m) - 1) / i) * (1 + i);
      yearlyTable.add(SipYearlyRow(
        year: y,
        invested: monthlyInvestment * m,
        futureValue: yearlyFv,
      ));
    }

    return SipResult(
      investedAmount: invested,
      estimatedReturns: fv - invested,
      totalValue: fv,
      yearlyTable: yearlyTable,
    );
  }
}
