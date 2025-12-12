class EthiopianDateUtils {
  static const List<String> _ethiopianMonths = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];

  static const List<String> _ethiopianDays = [
    'እሑድ', 'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ'
  ];

  /// Convert Gregorian date to Ethiopian date (Accurate conversion)
  static Map<String, int> gregorianToEthiopian(DateTime gregorianDate) {
    int year = gregorianDate.year;
    int month = gregorianDate.month;
    int day = gregorianDate.day;
    
    // Ethiopian calendar conversion
    // Ethiopian New Year: September 11 (or 12 in leap years)
    bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    int newYearDay = isLeapYear ? 12 : 11;
    
    int ethiopianYear;
    int ethiopianMonth;
    int ethiopianDay;
    
    if (month > 9 || (month == 9 && day >= newYearDay)) {
      // After Ethiopian New Year
      ethiopianYear = year - 7;
      
      if (month == 9) {
        ethiopianMonth = 1; // መስከረም
        ethiopianDay = day - newYearDay + 1;
      } else if (month == 10) {
        ethiopianMonth = 2; // ጥቅምት
        ethiopianDay = day - 10; // October 11 = ጥቅምት 1
        if (ethiopianDay <= 0) {
          ethiopianMonth = 1;
          ethiopianDay = 30 + ethiopianDay;
        }
      } else if (month == 11) {
        ethiopianMonth = 3; // ኅዳር
        ethiopianDay = day - 9; // November 10 = ኅዳር 1
        if (ethiopianDay <= 0) {
          ethiopianMonth = 2;
          ethiopianDay = 30 + ethiopianDay;
        }
      } else if (month == 12) {
        ethiopianMonth = 4; // ታኅሳስ
        ethiopianDay = day - 9; // December 10 = ታኅሳስ 1
        if (ethiopianDay <= 0) {
          ethiopianMonth = 3;
          ethiopianDay = 30 + ethiopianDay;
        }
      } else {
        // This shouldn't happen in this branch
        ethiopianMonth = 1;
        ethiopianDay = 1;
      }
    } else {
      // Before Ethiopian New Year (January to early September)
      ethiopianYear = year - 8;
      
      if (month == 1) {
        ethiopianMonth = 5; // ጥር
        ethiopianDay = day + 21; // January 1 = ጥር 22
        if (ethiopianDay > 30) {
          ethiopianMonth = 6;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 2) {
        ethiopianMonth = 6; // የካቲት
        ethiopianDay = day + 21; // February 1 = የካቲት 22
        if (ethiopianDay > 30) {
          ethiopianMonth = 7;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 3) {
        ethiopianMonth = 7; // መጋቢት
        ethiopianDay = day + 19; // March 1 = መጋቢት 20
        if (ethiopianDay > 30) {
          ethiopianMonth = 8;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 4) {
        ethiopianMonth = 8; // ሚያዝያ
        ethiopianDay = day + 21; // April 1 = ሚያዝያ 22
        if (ethiopianDay > 30) {
          ethiopianMonth = 9;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 5) {
        ethiopianMonth = 9; // ግንቦት
        ethiopianDay = day + 21; // May 1 = ግንቦት 22
        if (ethiopianDay > 30) {
          ethiopianMonth = 10;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 6) {
        ethiopianMonth = 10; // ሰኔ
        ethiopianDay = day + 22; // June 1 = ሰኔ 23
        if (ethiopianDay > 30) {
          ethiopianMonth = 11;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 7) {
        ethiopianMonth = 11; // ሐምሌ
        ethiopianDay = day + 22; // July 1 = ሐምሌ 23
        if (ethiopianDay > 30) {
          ethiopianMonth = 12;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 8) {
        ethiopianMonth = 12; // ነሐሴ
        ethiopianDay = day + 23; // August 1 = ነሐሴ 24
        if (ethiopianDay > 30) {
          ethiopianMonth = 13;
          ethiopianDay = ethiopianDay - 30;
        }
      } else if (month == 9 && day < newYearDay) {
        ethiopianMonth = 13; // ጳጉሜን
        ethiopianDay = day + 23; // September 1 = ጳጉሜን 24
      } else {
        ethiopianMonth = 1;
        ethiopianDay = 1;
      }
    }
    
    return {
      'year': ethiopianYear,
      'month': ethiopianMonth,
      'day': ethiopianDay,
    };
  }

  /// Format date for display
  static String formatDate(String gregorianDateString) {
    try {
      final gregorianDate = DateTime.parse(gregorianDateString);
      final ethiopianDate = gregorianToEthiopian(gregorianDate);
      
      // Fix weekday calculation: DateTime.weekday returns 1-7 (Monday-Sunday)
      // We need 0-6 (Sunday-Saturday) for Ethiopian days array
      int weekdayIndex = gregorianDate.weekday % 7; // Convert 1-7 to 0-6
      final dayOfWeek = _ethiopianDays[weekdayIndex];
      final monthName = _ethiopianMonths[ethiopianDate['month']! - 1];
      
      return '$dayOfWeek, ${ethiopianDate['day']} $monthName ${ethiopianDate['year']}';
    } catch (e) {
      // Fallback to Gregorian format with day name
      final date = DateTime.parse(gregorianDateString);
      final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final dayName = weekdays[date.weekday % 7];
      return '$dayName, ${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get current Ethiopian date
  static Map<String, int> getCurrentEthiopianDate() {
    return gregorianToEthiopian(DateTime.now());
  }

  /// Format Ethiopian date as string
  static String formatEthiopianDate(Map<String, int> ethiopianDate) {
    final monthName = _ethiopianMonths[ethiopianDate['month']! - 1];
    return '${ethiopianDate['day']} $monthName ${ethiopianDate['year']}';
  }

  /// Get today's date formatted with correct day name
  static String getTodayFormatted() {
    final today = DateTime.now();
    return formatDate(today.toIso8601String().split('T')[0]);
  }

  /// Get day name in Ethiopian
  static String getDayName(DateTime date) {
    int weekdayIndex = date.weekday % 7; // Convert 1-7 to 0-6
    return _ethiopianDays[weekdayIndex];
  }
}