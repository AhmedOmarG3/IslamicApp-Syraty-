import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

abstract class AppTextStyles {
  static const String fontFamilyAmiri = 'Amiri';

  // Typography Scale (Arabic RTL First)
  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 34.sp,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: AppColors.primaryGreen,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 18.sp,
        fontWeight: FontWeight.normal,
        height: 1.6,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 15.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  // App Bar & Specialized Typography
  static TextStyle get appBarTitle => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      );

  static TextStyle get ayahText => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        height: 2.5,
      );
}
