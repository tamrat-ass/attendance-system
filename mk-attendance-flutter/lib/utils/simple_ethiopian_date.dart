// Simplified Ethiopian Date Utility - Backup version
class SimpleEthiopianDateUtils {
  static const List<String> months = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];

  // Simple conversion - Ethiopian year is approximately Gregorian year - 7
  static String getCurrentGregorianForApi() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  // Simple Ethiopian date display
  static String formatEthiopianDate(Map<String, int> ethiopianDate) {
    final monthIndex = (ethiopianDate['month']! - 1).clamp(0, 12);
    final monthName = months[monthIndex];
    return '${ethiopianDate['day']} $monthName ${ethiopianDate['year']}';
  }

  // Simple conversion for display
  static Map<String, int> getCurrentEthiopianDate() {
    final now = DateTime.now();
    return {
      'year': now.year - 7,
      'month': now.month,
      'day': now.day,
    };
  }

  // Simple Gregorian to Ethiopian conversion
  static Map<String, int> gregorianToEthiopianFromString(String gregorianString) {
    try {
      final parts = gregorianString.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      return {
        'year': year - 7,
        'month': month,
        'day': day,
      };
    } catch (e) {
      return getCurrentEthiopianDate();
    }
  }

  // Simple Ethiopian to Gregorian conversion
  static String ethiopianToGregorian(Map<String, int> ethiopianDate) {
    final year = ethiopianDate['year']! + 7;
    final month = ethiopianDate['month']!;
    final day = ethiopianDate['day']!;
    
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}