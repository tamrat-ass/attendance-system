import 'package:flutter/material.dart';

class AppColors {
  // Elegant burgundy red color scheme - #A6322A
  static const Color primary = Color(0xFFA6322A);
  // Slightly darker variant for dark theme use
  static const Color primaryDark = Color(0xFF8B2A23);
  // Lighter variant for backgrounds
  static const Color primaryLight = Color(0xFFD4524A);

  // Dark blue colors for dark theme text
  static const Color darkBlue = Color(0xFF1A237E);
  static const Color darkBlueMedium = Color(0xFF283593);
  static const Color darkBlueLight = Color(0xFF3949AB);

  // Convenience method for light variants with opacity
  static Color primaryWithOpacity([double opacity = 0.08]) => primary.withOpacity(opacity);
}
