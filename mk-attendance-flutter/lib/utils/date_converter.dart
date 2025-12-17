import 'correct_ethiopian_date.dart';

/// Utility class to handle date conversion between Ethiopian and Gregorian formats
/// for database storage and API communication
class DateConverter {
  
  /// Convert Ethiopian date (YYYY-MM-DD) to Gregorian date (YYYY-MM-DD)
  /// Used when reading from database that stores Ethiopian dates
  static String ethiopianToGregorianDb(String ethiopianDbDate) {
    try {
      final parts = ethiopianDbDate.split('-');
      final ethiopianDate = {
        'year': int.parse(parts[0]),
        'month': int.parse(parts[1]),
        'day': int.parse(parts[2]),
      };
      
      // Convert Ethiopian to Gregorian
      return CorrectEthiopianDateUtils.ethiopianToGregorian(ethiopianDate);
    } catch (e) {
      // If parsing fails, return current Gregorian date
      return DateTime.now().toIso8601String().split('T')[0];
    }
  }
  
  /// Convert Gregorian date (YYYY-MM-DD) to Ethiopian date (YYYY-MM-DD)
  /// Used when writing to database that should store Ethiopian dates
  static String gregorianToEthiopianDb(String gregorianDate) {
    try {
      final date = DateTime.parse(gregorianDate);
      final ethiopianDate = CorrectEthiopianDateUtils.gregorianToEthiopian(date);
      
      final year = ethiopianDate['year'].toString().padLeft(4, '0');
      final month = ethiopianDate['month'].toString().padLeft(2, '0');
      final day = ethiopianDate['day'].toString().padLeft(2, '0');
      
      return '$year-$month-$day';
    } catch (e) {
      // If parsing fails, return current Ethiopian date
      return CorrectEthiopianDateUtils.getCurrentEthiopianForApi();
    }
  }
  
  /// Get current date in Ethiopian database format
  static String getCurrentEthiopianDb() {
    return CorrectEthiopianDateUtils.getCurrentEthiopianForApi();
  }
  
  /// Format Ethiopian database date for display
  static String formatEthiopianDbDate(String ethiopianDbDate) {
    try {
      final parts = ethiopianDbDate.split('-');
      final ethiopianDate = {
        'year': int.parse(parts[0]),
        'month': int.parse(parts[1]),
        'day': int.parse(parts[2]),
      };
      
      return CorrectEthiopianDateUtils.formatEthiopianDate(ethiopianDate);
    } catch (e) {
      return ethiopianDbDate; // Return as-is if parsing fails
    }
  }
  
  /// Check if a date string is in Ethiopian format
  static bool isEthiopianFormat(String dateString) {
    try {
      final parts = dateString.split('-');
      final year = int.parse(parts[0]);
      final currentEthiopianYear = CorrectEthiopianDateUtils.getCurrentEthiopianDate()['year']!;
      
      // Ethiopian format if year is within reasonable range of current Ethiopian year
      return year >= (currentEthiopianYear - 10) && year <= (currentEthiopianYear + 10);
    } catch (e) {
      return false;
    }
  }
  
  /// Convert any date format to Ethiopian database format
  /// Handles both Ethiopian and Gregorian input dates
  static String toEthiopianDb(String dateString) {
    if (isEthiopianFormat(dateString)) {
      return dateString; // Already in Ethiopian format
    } else {
      return gregorianToEthiopianDb(dateString); // Convert from Gregorian
    }
  }
}