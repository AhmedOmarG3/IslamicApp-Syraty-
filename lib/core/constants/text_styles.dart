import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';

abstract class AppTextStyles {
  static const String fontFamilyAmiri = 'Amiri';

  // Typography Scale (Arabic RTL First)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: AppColors.primaryGreen,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // App Bar & Specialized Typography
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGreen,
  );

  static const TextStyle ayahText = TextStyle(
    fontFamily: fontFamilyAmiri,
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGreen,
    height: 2.5,
  );
}
