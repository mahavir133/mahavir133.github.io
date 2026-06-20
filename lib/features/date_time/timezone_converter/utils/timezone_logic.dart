import 'package:timezone/timezone.dart' as tz;

class TimeZoneLogic {
  static List<String> getAvailableTimeZones() {
    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  static tz.TZDateTime convertTime({
    required DateTime time,
    required String fromZoneName,
    required String toZoneName,
  }) {
    final fromZone = tz.getLocation(fromZoneName);
    final toZone = tz.getLocation(toZoneName);

    // Create a TZDateTime in the original zone
    final originalTime = tz.TZDateTime(
      fromZone,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    );

    // Convert to target zone
    return tz.TZDateTime.from(originalTime, toZone);
  }
}
