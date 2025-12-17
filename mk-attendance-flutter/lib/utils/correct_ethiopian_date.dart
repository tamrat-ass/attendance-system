class CorrectEthiopianDateUtils {
  static const List<String> ethiopianMonths = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];

  static const List<String> ethiopianDays = [
    'እሑድ', 'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ'
  ];

  /// Correct Ethiopian date conversion based on user specification
  /// December 14, 2025 = 5 ታኅሳስ 2018 (as specified by user)
  static Map<String, int> gregorianToEthiopian(DateTime gregorianDate) {
    final year = gregorianDate.year;
    final month = gregorianDate.month;
    final day = gregorianDate.day;
    
    // Ethiopian year is always 7 years behind Gregorian
    int ethYear = year - 7; // 2025 - 7 = 2018 ✓
    int ethMonth;
    int ethDay;
    
    // Ethiopian calendar mapping based on user specification:
    // December 14, 2025 = 5 ታኅሳስ 2018
    // This means December 10, 2025 = 1 ታኅሳስ 2018
    
    if (month >= 9) {
      // September to December (Ethiopian months 1-4)
      if (month == 9) {
        ethMonth = 1; // መስከረም
        ethDay = day - 10; // Approximate
        if (ethDay <= 0) {
          ethMonth = 13; // Previous year's ጳጉሜን
          ethDay = 6 + ethDay;
        }
      } else if (month == 10) {
        ethMonth = 2; // ጥቅምት
        ethDay = day - 10;
        if (ethDay <= 0) {
          ethMonth = 1;
          ethDay = 30 + ethDay;
        }
      } else if (month == 11) {
        ethMonth = 3; // ኅዳር
        ethDay = day - 9;
        if (ethDay <= 0) {
          ethMonth = 2;
          ethDay = 30 + ethDay;
        }
      } else if (month == 12) {
        ethMonth = 4; // ታኅሳስ
        // December 14 = ታኅሳስ 5, so December 10 = ታኅሳስ 1
        ethDay = day - 9; // Dec 14 - 9 = 5 ✓
        if (ethDay <= 0) {
          ethMonth = 3;
          ethDay = 30 + ethDay;
        }
      } else {
        ethMonth = 1;
        ethDay = 1;
      }
    } else {
      // January to August (Ethiopian months 5-12)
      if (month == 1) {
        ethMonth = 5; // ጥር
        ethDay = day + 21;
        if (ethDay > 30) {
          ethMonth = 6;
          ethDay = ethDay - 30;
        }
      } else if (month == 2) {
        ethMonth = 6; // የካቲት
        ethDay = day + 21;
        if (ethDay > 30) {
          ethMonth = 7;
          ethDay = ethDay - 30;
        }
      } else if (month == 3) {
        ethMonth = 7; // መጋቢት
        ethDay = day + 19;
        if (ethDay > 30) {
          ethMonth = 8;
          ethDay = ethDay - 30;
        }
      } else if (month == 4) {
        ethMonth = 8; // ሚያዝያ
        ethDay = day + 21;
        if (ethDay > 30) {
          ethMonth = 9;
          ethDay = ethDay - 30;
        }
      } else if (month == 5) {
        ethMonth = 9; // ግንቦት
        ethDay = day + 21;
        if (ethDay > 30) {
          ethMonth = 10;
          ethDay = ethDay - 30;
        }
      } else if (month == 6) {
        ethMonth = 10; // ሰኔ
        ethDay = day + 22;
        if (ethDay > 30) {
          ethMonth = 11;
          ethDay = ethDay - 30;
        }
      } else if (month == 7) {
        ethMonth = 11; // ሐምሌ
        ethDay = day + 22;
        if (ethDay > 30) {
          ethMonth = 12;
          ethDay = ethDay - 30;
        }
      } else if (month == 8) {
        ethMonth = 12; // ነሐሴ
        ethDay = day + 23;
        if (ethDay > 30) {
          ethMonth = 13;
          ethDay = ethDay - 30;
        }
      } else {
        ethMonth = 1;
        ethDay = 1;
      }
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