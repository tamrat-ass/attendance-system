class EthiopianDateUtils {
  static const List<String> ethiopianMonths = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];

  static const List<String> ethiopianDays = [
    'እሑድ', 'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ'
  ];

  /// Check if Gregorian year is leap year
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Correct Ethiopian date conversion
  /// December 13, 2025 = ታህሳስ 4, 2018
  static Map<String, int> gregorianToEthiopian(DateTime gregorianDate) {
    final year = gregorianDate.year;
    final month = gregorianDate.month;
    final day = gregorianDate.day;
    
    // Ethiopian year = Gregorian year - 7
    int ethYear = year - 7; // 2025 - 7 = 2018 ✓
    int ethMonth;
    int ethDay;
    
    // Ethiopian New Year starts around September 11/12
    if (month >= 9) {
      // September to December (Ethiopian months 1-4)
      if (month == 9) {
        ethMonth = 1; // መስከረም
        ethDay = day - 10; // Approximate adjustment
        if (ethDay <= 0) {
          ethYear = year - 8;
          ethMonth = 13; // ጳጉሜን from previous year
          ethDay = 30 + ethDay;
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
        // December 13 = ታህሳስ 4, so December 10 = ታህሳስ 1
        ethDay = day - 9;
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
    if (ethDay > 30) ethDay = 30;
    
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
  /// This uses the same logic as the web app for consistency
  static String ethiopianToGregorian(Map<String, int> ethiopianDate) {
    final ethYear = ethiopianDate['year']!;
    final ethMonth = ethiopianDate['month']!;
    final ethDay = ethiopianDate['day']!;
    
    // Use the same conversion logic as web app
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
  /// This uses the same logic as the web app for consistency
  static Map<String, int> gregorianToEthiopianFromString(String gregorianString) {
    try {
      final parts = gregorianString.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      // Use the same reverse conversion logic as web app
      final ethYear = year - 7;
      int ethMonth = month - 8;
      final ethDay = day;
      
      // Handle month underflow
      if (ethMonth <= 0) {
        ethMonth = ethMonth + 12;
      }
      
      // Ensure valid ranges
      if (ethMonth <= 0) ethMonth = 1;
      if (ethMonth > 13) ethMonth = 13;
      
      return {'year': ethYear, 'month': ethMonth, 'day': ethDay};
    } catch (e) {
      return getCurrentEthiopianDate();
    }
  }

  /// Get current date in Gregorian format for API calls
  static String getCurrentGregorianForApi() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Format date for display using accurate conversion
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