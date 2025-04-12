import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryColor = Color(0xFFE5AD57); // Warm golden
  static const Color primaryLight = Color(0xFFF2D4A7); // Light golden
  static const Color primaryDark = Color(0xFFB88A45); // Dark golden
  
  // Neutral colors
  static const Color neutral900 = Color(0xFF2D3047); // Deep blue-grey
  static const Color neutral800 = Color(0xFF424867);
  static const Color neutral700 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFFAF7F2);

  // Semantic colors
  static const Color success = Color(0xFF419D78);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF09D51);
  static const Color info = Color(0xFF3B82F6);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: primaryDark,
      surface: Colors.white,
      background: neutral100,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: neutral900,
      onBackground: neutral900,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: neutral100,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: neutral900,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: neutral900),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: neutral400),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(
        color: neutral600,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: neutral700,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: neutral400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: neutral400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: neutral900,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: neutral900,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neutral900,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: neutral900,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: neutral900,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: neutral700,
      ),
    ),
    iconTheme: IconThemeData(
      color: neutral700,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: neutral400,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryDark,
      secondary: primaryLight,
      surface: neutral900,
      background: const Color(0xFF1A1C2A),
      error: error,
      onPrimary: Colors.white,
      onSecondary: neutral900,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1C2A),
    appBarTheme: AppBarTheme(
      backgroundColor: neutral900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: neutral900,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: neutral800),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: neutral900,
      hintStyle: TextStyle(
        color: neutral600,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: neutral500,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: neutral700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: neutral700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: neutral400,
      ),
    ),
    iconTheme: IconThemeData(
      color: neutral400,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: neutral800,
      thickness: 1,
    ),
  );
} 