import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

abstract class AppTextStyles {
  static const String fontFamilyAmiri = 'Amiri';

  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: AppColors.textWhite,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: AppColors.textWhite,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: AppColors.textWhite,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        height: 1.6,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: AppColors.textMuted,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AppColors.textDimmed,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textMuted,
      );

  static TextStyle get appBarTitle => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      );

  static TextStyle get ayahText => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 24.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
        height: 2.1,
      );

  static TextStyle get buttonLabel => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: AppColors.textWhite,
      );

  static TextStyle get goldAccent => TextStyle(
        fontFamily: fontFamilyAmiri,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.accentGold,
      );
}
