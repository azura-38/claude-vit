import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Format: "15 Oct 2023" or "15 Eki 2023"
  static String formatShort(DateTime date, {String locale = 'en'}) {
    return DateFormat('d MMM y', locale).format(date);
  }

  /// Format: "15 October 2023" or "15 Ekim 2023"
  static String formatLong(DateTime date, {String locale = 'en'}) {
    return DateFormat('d MMMM y', locale).format(date);
  }

  /// Format: "2023-10-15" (ISO date only)
  static String formatIso(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format: "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Day number: "15"
  static String day(DateTime date) => date.day.toString();

  /// Short month
  static String monthShort(DateTime date, {String locale = 'en'}) {
    return DateFormat('MMM', locale).format(date);
  }

  /// Year: "2023"
  static String year(DateTime date) => date.year.toString();

  /// Weekday short: "Mon" or "Pzt"
  static String weekdayShort(DateTime date, {String locale = 'en'}) {
    return DateFormat('E', locale).format(date);
  }

  /// Full month name
  static String getMonthName(int month, {String locale = 'en'}) {
    final date = DateTime(2000, month, 1);
    return DateFormat('MMMM', locale).format(date);
  }
}
