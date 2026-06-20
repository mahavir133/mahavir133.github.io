import 'package:intl/intl.dart';

class TimestampResult {
  final DateTime dateTime;
  final String iso8601;
  final String humanReadable;
  final String relativeTime;

  TimestampResult({
    required this.dateTime,
    required this.iso8601,
    required this.humanReadable,
    required this.relativeTime,
  });
}

class TimestampLogic {
  static TimestampResult fromUnix(int timestamp) {
    // Determine if it's seconds or milliseconds
    // A timestamp in seconds for year 2000+ is ~1 billion
    // A timestamp in milliseconds is ~1 trillion
    DateTime dt;
    if (timestamp > 9999999999) {
      dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }

    return _createResult(dt);
  }

  static TimestampResult fromDateTime(DateTime dt) {
    return _createResult(dt);
  }

  static TimestampResult _createResult(DateTime dt) {
    final iso = dt.toIso8601String();
    final human = DateFormat('MMMM dd, yyyy - hh:mm:ss a').format(dt);
    final relative = _getRelativeTime(dt);

    return TimestampResult(
      dateTime: dt,
      iso8601: iso,
      humanReadable: human,
      relativeTime: relative,
    );
  }

  static String _getRelativeTime(DateTime target) {
    final now = DateTime.now();
    final diff = now.difference(target);

    if (diff.isNegative) {
      // Future
      final absDiff = diff.abs();
      if (absDiff.inDays > 365) return 'In ${absDiff.inDays ~/ 365} years';
      if (absDiff.inDays > 30) return 'In ${absDiff.inDays ~/ 30} months';
      if (absDiff.inDays > 0) return 'In ${absDiff.inDays} days';
      if (absDiff.inHours > 0) return 'In ${absDiff.inHours} hours';
      if (absDiff.inMinutes > 0) return 'In ${absDiff.inMinutes} mins';
      return 'In a few seconds';
    } else {
      // Past
      if (diff.inDays > 365) return '${diff.inDays ~/ 365} years ago';
      if (diff.inDays > 30) return '${diff.inDays ~/ 30} months ago';
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
      return 'Just now';
    }
  }
}
