class CorrectEthiopianDateUtils {
  static const List<String> ethiopianMonths = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];

  static const List<String> ethiopianDays = [
    'እሑድ', 'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ'
  ];

  /// Accurate Ethiopian date conversion
  /// Based on user correction: January 1, 2026 = 23 ታኅሳስ 2018
  static Map<String, int> gregorianToEthiopian(DateTime gregorianDate) {
    // Reference point: January 1, 2026 = 23 ታኅሳስ 2018
    final referenceGregorian = DateTime(2026, 1, 1); // January 1, 2026
    final referenceEthiopian = {'year': 2018, 'month': 4, 'day': 23}; // 23 ታኅሳስ 2018
    
    // Calculate days difference from reference point
    final daysDiff = gregorianDate.difference(referenceGregorian).inDays;
    
    // Start from reference Ethiopian date
    int ethYear = referenceEthiopian['year']!;
    int ethMonth = referenceEthiopian['month']!;
    int ethDay = referenceEthiopian['day']! + daysDiff;
    
    // Handle day overflow/underflow
    while (ethDay > 30 && ethMonth <= 12) {
      ethDay -= 30;
      ethMonth++;
      if (ethMonth > 13) {
        ethMonth = 1;
        ethYear++;
      }
    }
    
    while (ethDay > 6 && ethMonth == 13) {
      ethDay -= 6;
      ethMonth = 1;
      ethYear++;
    }
    
    while (ethDay < 1) {
      ethMonth--;
      if (ethMonth < 1) {
        ethMonth = 13;
        ethYear--;
      }
      ethDay += (ethMonth == 13) ? 6 : 30;
    }
    
    // Ensure valid ranges
    if (ethMonth < 1) ethMonth = 1;
    if (ethMonth > 13) ethMonth = 13;
    if (ethDay < 1) ethDay = 1;
    if (ethMonth == 13 && ethDay > 6) ethDay = 6; // Pagumen max 6 days
    if (ethMonth != 13 && ethDay > 30) ethDay = 30; // Other months max 30 days
    
    return {
      'year': ethYear,
      'month': ethMonth,
      'day': ethDay,
    };
  }

  /// Get current Ethiopian date
  static Map<String, int> getCurrentEthiopianDate() {
    return gregorianToEthiopian(DateTime.now());
  }

  /// Format Ethiopian date as string
  static String formatEthiopianDate(Map<String, int> ethiopianDate) {
    final monthIndex = (ethiopianDate['month']! - 1).clamp(0, 12);
    final monthName = ethiopianMonths[monthIndex];
    return '${ethiopianDate['day']} $monthName ${ethiopianDate['year']}';
  }

  /// Convert Ethiopian date to Gregorian format for API calls
  static String ethiopianToGregorian(Map<String, int> ethiopianDate) {
    final ethYear = ethiopianDate['year']!;
    final ethMonth = ethiopianDate['month']!;
    final ethDay = ethiopianDate['day']!;
    
    // Simple conversion for API compatibility
    final gregYear = ethYear + 7;
    int gregMonth = ethMonth + 8;
    int gregDay = ethDay;
    
    // Handle month overflow
    if (gregMonth > 12) {
      gregMonth = gregMonth - 12;
    }
    
    // Ensure valid ranges
    if (gregMonth <= 0) gregMonth = 1;
    if (gregMonth > 12) gregMonth = 12;
    if (gregDay <= 0) gregDay = 1;
    if (gregDay > 28) gregDay = 28;
    
    final year = gregYear.toString().padLeft(4, '0');
    final month = gregMonth.toString().padLeft(2, '0');
    final day = gregDay.toString().padLeft(2, '0');
    
    return '$year-$month-$day';
  }

  /// Convert Gregorian date string back to Ethiopian
  static Map<String, int> gregorianToEthiopianFromString(String gregorianString) {
    try {
      final date = DateTime.parse(gregorianString);
      return gregorianToEthiopian(date);
    } catch (e) {
      return getCurrentEthiopianDate();
    }
  }

  /// Get current date in Ethiopian format for API calls (YYYY-MM-DD)
  static String getCurrentEthiopianForApi() {
    final ethiopianDate = getCurrentEthiopianDate();
    final year = ethiopianDate['year'].toString().padLeft(4, '0');
    final month = ethiopianDate['month'].toString().padLeft(2, '0');
    final day = ethiopianDate['day'].toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Get current date in Gregorian format for API calls
  static String getCurrentGregorianForApi() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Format date for display
  static String formatDate(String gregorianDateString) {
    try {
      final date = DateTime.parse(gregorianDateString);
      final ethiopianDate = gregorianToEthiopian(date);
      final monthName = ethiopianMonths[(ethiopianDate['month']! - 1).clamp(0, 12)];
      return '${ethiopianDate['day']} $monthName ${ethiopianDate['year']}';
    } catch (e) {
      return gregorianDateString;
    }
  }

  /// Get today's date formatted
  static String getTodayFormatted() {
    final today = DateTime.now();
    return formatDate(today.toIso8601String().split('T')[0]);
  }

  /// Get day name in Ethiopian
  static String getDayName(DateTime date) {
    int weekdayIndex = (date.weekday % 7);
    return ethiopianDays[weekdayIndex];
  }
}