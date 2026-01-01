// Simplified Ethiopian Date Utility - Updated with correct conversion
class SimpleEthiopianDateUtils {
  static const List<String> months = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];

  // Simple conversion for display - Updated with correct algorithm
  static Map<String, int> getCurrentEthiopianDate() {
    return gregorianToEthiopian(DateTime.now());
  }

  // Accurate Gregorian to Ethiopian conversion
  // Based on user correction: January 1, 2026 = 23 ታኅሳስ 2018
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

  // Simple Ethiopian to Gregorian conversion
  static String ethiopianToGregorian(Map<String, int> ethiopianDate) {
    final year = ethiopianDate['year']! + 7;
    final month = ethiopianDate['month']!;
    final day = ethiopianDate['day']!;
    
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}