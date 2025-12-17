import 'package:flutter/material.dart';

class AppColors {
  // Elegant burgundy red color scheme - #A6322A
  static const Color primary = Color(0xFFA6322A);
  // Slightly darker variant for dark theme use
  static const Color primaryDark = Color(0xFF8B2A23);
  // Lighter variant for backgrounds
  static const Color primaryLight = Color(0xFFD4524A);

  // Convenience method for light variants with opacity
  static Color primaryWithOpacity([double opacity = 0.08]) => primary.withOpacity(opacity);
}
