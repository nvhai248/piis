import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF7B61FF);
  static const secondary = Color(0xFFB388FF);
  static const background = Color(0xFFF5F5F5);
  static const textDark = Color(0xFF2D2D2D);
  static const textLight = Color(0xFF757575);
  
  // Service card colors
  static const daycareBg = Color(0xFFE3F2FD);
  static const healthBg = Color(0xFFE8F5E9);
  static const groomingBg = Color(0xFFF3E5F5);
  static const trackingBg = Color(0xFFFFEBEE);
}

class AppStyles {
  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );
} 