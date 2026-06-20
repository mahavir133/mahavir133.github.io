import 'dart:math';

class EmiResult {
  final double emi;
  final double totalInterest;
  final double totalPayment;
  final List<AmortizationRow> amortizationTable;

  EmiResult({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.amortizationTable,
  });
}

class AmortizationRow {
  final int month;
  final double principalPaid;
  final double interestPaid;
  final double balance;

  AmortizationRow({
    required this.month,
    required this.principalPaid,
    required this.interestPaid,
    required this.balance,
  });
}

class EmiCalculator {
  static EmiResult calculate({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) {
      return EmiResult(
        emi: 0,
        totalInterest: 0,
        totalPayment: 0,
        amortizationTable: [],
      );
    }

    if (annualInterestRate <= 0) {
      final emi = principal / tenureMonths;
      return EmiResult(
        emi: emi,
        totalInterest: 0,
        totalPayment: principal,
        amortizationTable: List.generate(tenureMonths, (i) {
          final balance = principal - (emi * (i + 1));
          return AmortizationRow(
            month: i + 1,
            principalPaid: emi,
            interestPaid: 0,
            balance: balance > 0 ? balance : 0,
          );
        }),
      );
    }

    final double r = annualInterestRate / 12 / 100;
    final double emi =
        principal * r * (pow(1 + r, tenureMonths)) / (pow(1 + r, tenureMonths) - 1);

    double remainingPrincipal = principal;
    double totalInterest = 0;
    final List<AmortizationRow> table = [];

    for (int i = 1; i <= tenureMonths; i++) {
      final interestForMonth = remainingPrincipal * r;
      final principalForMonth = emi - interestForMonth;
      
      remainingPrincipal -= principalForMonth;
      if (remainingPrincipal < 0) remainingPrincipal = 0;
      
      totalInterest += interestForMonth;

      table.add(AmortizationRow(
        month: i,
        principalPaid: principalForMonth,
        interestPaid: interestForMonth,
        balance: remainingPrincipal,
      ));
    }

    return EmiResult(
      emi: emi,
      totalInterest: totalInterest,
      totalPayment: principal + totalInterest,
      amortizationTable: table,
    );
  }
}
