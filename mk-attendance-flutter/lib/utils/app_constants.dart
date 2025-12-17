class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://mk-attendance.vercel.app/api';
  static const String webAppUrl = 'https://mk-attendance.vercel.app';
  
  // App Information
  static const String appName = 'MK Attendance';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Mobile Attendance Management System';
  
  // Storage Keys
  static const String userKey = 'user';
  static const String tokenKey = 'auth_token';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int connectionTimeout = 10; // seconds
  
  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 1000;
  
  // File Export
  static const String csvMimeType = 'text/csv';
  static const String csvExtension = '.csv';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxPhoneLength = 15;
  
  // Colors (Material Design)
  static const int primaryColorValue = 0xFF2196F3; // Blue
  static const int successColorValue = 0xFF4CAF50; // Green
  static const int errorColorValue = 0xFF751F1F; // Primary (replaced red)
  static const int warningColorValue = 0xFFFF9800; // Orange
  
  // Status Values
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';
  static const String statusPermission = 'permission';
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleUser = 'user';
  
  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String dataError = 'Failed to load data. Please try again.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String logoutSuccess = 'Logout successful';
  static const String saveSuccess = 'Data saved successfully';
  static const String syncSuccess = 'Data synchronized successfully';
  
  // Ethiopian Calendar
  static const List<String> ethiopianMonths = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
  ];
  
  static const List<String> ethiopianDays = [
    'እሑድ', 'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ'
  ];
  
  // Status Translations
  static const Map<String, String> statusTranslations = {
    'present': 'ተገኝቷል',
    'absent': 'ተቀምጧል',
    'late': 'ዘግይቷል',
    'permission': 'ፈቃድ',
  };
}