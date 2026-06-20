class SalaryResult {
  final double hourly;
  final double daily;
  final double weekly;
  final double biWeekly;
  final double monthly;
  final double yearly;

  SalaryResult({
    required this.hourly,
    required this.daily,
    required this.weekly,
    required this.biWeekly,
    required this.monthly,
    required this.yearly,
  });
}

enum SalaryFrequency { hourly, daily, weekly, monthly, yearly }

class SalaryCalculator {
  static SalaryResult calculate({
    required double amount,
    required SalaryFrequency frequency,
    double hoursPerWeek = 40,
    double daysPerWeek = 5,
  }) {
    if (amount <= 0 || hoursPerWeek <= 0 || daysPerWeek <= 0) {
      return SalaryResult(hourly: 0, daily: 0, weekly: 0, biWeekly: 0, monthly: 0, yearly: 0);
    }

    double yearly = 0;

    switch (frequency) {
      case SalaryFrequency.hourly:
        yearly = amount * hoursPerWeek * 52;
        break;
      case SalaryFrequency.daily:
        yearly = amount * daysPerWeek * 52;
        break;
      case SalaryFrequency.weekly:
        yearly = amount * 52;
        break;
      case SalaryFrequency.monthly:
        yearly = amount * 12;
        break;
      case SalaryFrequency.yearly:
        yearly = amount;
        break;
    }

    final monthly = yearly / 12;
    final weekly = yearly / 52;
    final biWeekly = yearly / 26;
    final daily = weekly / daysPerWeek;
    final hourly = weekly / hoursPerWeek;

    return SalaryResult(
      hourly: hourly,
      daily: daily,
      weekly: weekly,
      biWeekly: biWeekly,
      monthly: monthly,
      yearly: yearly,
    );
  }
}
