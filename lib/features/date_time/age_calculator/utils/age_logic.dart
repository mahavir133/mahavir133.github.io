class AgeResult {
  final int years;
  final int months;
  final int days;

  final int nextBirthdayMonths;
  final int nextBirthdayDays;

  final int totalMonths;
  final int totalDays;
  final int totalHours;

  AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.nextBirthdayMonths,
    required this.nextBirthdayDays,
    required this.totalMonths,
    required this.totalDays,
    required this.totalHours,
  });
}

class AgeLogic {
  static AgeResult calculate(DateTime birthDate) {
    final now = DateTime.now();

    // Normalize to midnight to avoid time issues
    final bDate = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final today = DateTime(now.year, now.month, now.day);

    if (bDate.isAfter(today)) {
      return AgeResult(
        years: 0,
        months: 0,
        days: 0,
        nextBirthdayMonths: 0,
        nextBirthdayDays: 0,
        totalMonths: 0,
        totalDays: 0,
        totalHours: 0,
      );
    }

    int years = today.year - bDate.year;
    int months = today.month - bDate.month;
    int days = today.day - bDate.day;

    if (days < 0) {
      months--;
      // Get the number of days in the previous month
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    // Next birthday calculation
    DateTime nextBday = DateTime(today.year, bDate.month, bDate.day);
    if (nextBday.isBefore(today) || nextBday.isAtSameMomentAs(today)) {
      nextBday = DateTime(today.year + 1, bDate.month, bDate.day);
    }

    int nextMonths = nextBday.month - today.month;
    int nextDays = nextBday.day - today.day;

    if (nextDays < 0) {
      nextMonths--;
      final prevMonth = DateTime(nextBday.year, nextBday.month, 0);
      nextDays += prevMonth.day;
    }
    if (nextMonths < 0) {
      nextMonths += 12;
    }

    // Totals
    final difference = now.difference(birthDate);
    final totalDays = difference.inDays;
    final totalHours = difference.inHours;
    final totalMonthsCalc = (years * 12) + months;

    return AgeResult(
      years: years,
      months: months,
      days: days,
      nextBirthdayMonths: nextMonths,
      nextBirthdayDays: nextDays,
      totalMonths: totalMonthsCalc,
      totalDays: totalDays,
      totalHours: totalHours,
    );
  }
}
