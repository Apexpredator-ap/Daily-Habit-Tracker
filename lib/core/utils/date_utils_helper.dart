import 'package:intl/intl.dart';

class DateUtilsHelper {
  DateUtilsHelper._();

  static final DateFormat _ymdFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat _readableDateFormatter = DateFormat('EEEE, MMM d');
  static final DateFormat _shortDayFormatter = DateFormat('E');

  /// Formats DateTime to yyyy-MM-dd in local timezone
  static String toDateKey(DateTime date) {
    return _ymdFormatter.format(date.toLocal());
  }

  /// Parses yyyy-MM-dd string back to DateTime (local)
  static DateTime parseDateKey(String key) {
    return _ymdFormatter.parseStrict(key);
  }

  /// Returns today's date formatted as yyyy-MM-dd in local timezone
  static String todayDateKey() {
    return toDateKey(DateTime.now());
  }

  /// Formats date to a human readable format e.g. "Monday, Oct 19"
  static String formatReadable(DateTime date) {
    return _readableDateFormatter.format(date.toLocal());
  }

  /// Formats date to short day label e.g. "Mon"
  static String formatShortDay(DateTime date) {
    return _shortDayFormatter.format(date.toLocal());
  }

  /// Returns a list of past N days (inclusive of today), sorted ascending
  static List<DateTime> getPastDays(int count, {DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    return List.generate(count, (index) {
      return today.subtract(Duration(days: count - 1 - index));
    });
  }

  /// Normalizes a DateTime to start of day in local time
  static DateTime startOfDay(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
