class WorkingDaysResult {
  final DateTime targetDate;
  final int totalCalendarDays;

  WorkingDaysResult({
    required this.targetDate,
    required this.totalCalendarDays,
  });
}

class WorkingDaysLogic {
  static WorkingDaysResult addWorkingDays({
    required DateTime startDate,
    required int daysToAdd,
    required bool excludeWeekends,
    required List<DateTime> customHolidays,
  }) {
    int added = 0;
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    int step = daysToAdd >= 0 ? 1 : -1;
    int target = daysToAdd.abs();

    while (added < target) {
      current = current.add(Duration(days: step));

      bool isWeekend =
          current.weekday == DateTime.saturday ||
          current.weekday == DateTime.sunday;
      bool isHoliday = _isHoliday(current, customHolidays);

      if ((!excludeWeekends || !isWeekend) && !isHoliday) {
        added++;
      }
    }

    final diff = current.difference(startDate).inDays;

    return WorkingDaysResult(
      targetDate: current,
      totalCalendarDays: diff.abs(),
    );
  }

  static bool _isHoliday(DateTime date, List<DateTime> holidays) {
    for (var h in holidays) {
      if (h.year == date.year && h.month == date.month && h.day == date.day) {
        return true;
      }
    }
    return false;
  }

  // Helper to generate some standard holidays (US / UK / IN style approximations)
  static List<DateTime> getStandardHolidays(int year, String region) {
    if (region == 'US') {
      return [
        DateTime(year, 1, 1), // New Year
        DateTime(year, 7, 4), // Independence
        DateTime(year, 12, 25), // Christmas
      ];
    } else if (region == 'UK') {
      return [
        DateTime(year, 1, 1),
        DateTime(year, 12, 25),
        DateTime(year, 12, 26), // Boxing day
      ];
    } else if (region == 'IN') {
      return [
        DateTime(year, 1, 26), // Republic Day
        DateTime(year, 8, 15), // Independence Day
        DateTime(year, 10, 2), // Gandhi Jayanti
      ];
    }
    return [];
  }
}
