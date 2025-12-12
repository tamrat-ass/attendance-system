import 'package:intl/intl.dart';
import 'ethiopian_date.dart';

class DateHelper {
  // Date formatters
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yyyy');
  static final DateFormat _longDateFormat = DateFormat('EEEE, MMMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  // Get current date in API format
  static String getCurrentApiDate() {
    return _apiDateFormat.format(DateTime.now());
  }

  // Get current date for display
  static String getCurrentDisplayDate() {
    return _displayDateFormat.format(DateTime.now());
  }

  // Get current Ethiopian date for display
  static String getCurrentEthiopianDisplayDate() {
    final ethiopianDate = EthiopianDateUtils.getCurrentEthiopianDate();
    return EthiopianDateUtils.formatEthiopianDate(ethiopianDate);
  }

  // Get Ethiopian date string from DateTime
  static String getEthiopianDateString(DateTime date) {
    final ethiopianDate = EthiopianDateUtils.gregorianToEthiopian(date);
    return EthiopianDateUtils.formatEthiopianDate(ethiopianDate);
  }

  // Get Ethiopian date string from API format
  static String getEthiopianDateFromApi(String dateString) {
    try {
      final date = fromApiFormat(dateString);
      return getEthiopianDateString(date);
    } catch (e) {
      return dateString;
    }
  }

  // Convert DateTime to API format
  static String toApiFormat(DateTime date) {
    return _apiDateFormat.format(date);
  }

  // Convert API date string to DateTime
  static DateTime fromApiFormat(String dateString) {
    return _apiDateFormat.parse(dateString);
  }

  // Format date for display
  static String formatForDisplay(DateTime date) {
    return _displayDateFormat.format(date);
  }

  // Format date string for display
  static String formatDateString(String dateString) {
    try {
      final date = fromApiFormat(dateString);
      return formatForDisplay(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  // Get short date format
  static String formatShort(DateTime date) {
    return _shortDateFormat.format(date);
  }

  // Get long date format
  static String formatLong(DateTime date) {
    return _longDateFormat.format(date);
  }

  // Get time format
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  // Get date and time format
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  // Get relative date string (Today, Yesterday, Tomorrow, or formatted date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      return formatForDisplay(date);
    }
  }

  // Get relative date string from API format
  static String getRelativeDateStringFromApi(String dateString) {
    try {
      final date = fromApiFormat(dateString);
      return getRelativeDateString(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Generate date range
  static List<DateTime> generateDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  // Generate API date range
  static List<String> generateApiDateRange(DateTime start, DateTime end) {
    return generateDateRange(start, end)
        .map((date) => toApiFormat(date))
        .toList();
  }

  // Get weekday name
  static String getWeekdayName(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[date.weekday - 1];
  }

  // Get month name
  static String getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  // Validate date string
  static bool isValidDateString(String dateString) {
    try {
      _apiDateFormat.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Get time ago string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}