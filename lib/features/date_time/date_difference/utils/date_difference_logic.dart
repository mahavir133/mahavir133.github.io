class DateDifferenceResult {
  final int totalDays;
  final int businessDays;
  final int totalWeeks;
  final int totalMonths;
  final int totalYears;

  DateDifferenceResult({
    required this.totalDays,
    required this.businessDays,
    required this.totalWeeks,
    required this.totalMonths,
    required this.totalYears,
  });
}

class DateDifferenceLogic {
  static DateDifferenceResult calculate(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    // Reset times to midnight to avoid daylight saving time offset issues
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    final difference = endDate.difference(startDate);
    final totalDays = difference.inDays;

    final totalWeeks = totalDays ~/ 7;

    // Approximate months/years or exact?
    // Let's do exact calendar differences
    int totalMonths =
        (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
    if (endDate.day < startDate.day) {
      totalMonths--;
    }

    int totalYears = endDate.year - startDate.year;
    if (endDate.month < startDate.month ||
        (endDate.month == startDate.month && endDate.day < startDate.day)) {
      totalYears--;
    }

    // Business days (exclude Saturday and Sunday)
    int businessDays = 0;
    DateTime current = startDate;
    while (current.isBefore(endDate)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return DateDifferenceResult(
      totalDays: totalDays,
      businessDays: businessDays,
      totalWeeks: totalWeeks,
      totalMonths: totalMonths,
      totalYears: totalYears,
    );
  }
}
