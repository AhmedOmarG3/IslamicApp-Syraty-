import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/text_styles.dart';

abstract class AppTheme {
  /// Figma Luxury Islamic Light Theme (Matching user screenshot)
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.sageGreenDark,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.navPillActiveLight,
      onPrimaryContainer: AppColors.textDarkPrimary,
      secondary: AppColors.accentGold,
      onSecondary: AppColors.white,
      surface: AppColors.cardLight,
      onSurface: AppColors.textDarkPrimary,
      error: AppColors.errorRed,
      outline: AppColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamilyAmiri,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgLight,
      cardColor: AppColors.cardLight,
      dividerColor: AppColors.borderLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        foregroundColor: AppColors.textDarkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: AppDimensions.appBarHeight,
        titleTextStyle: AppTextStyles.appBarTitle
            .copyWith(color: AppColors.textDarkPrimary),
        iconTheme: const IconThemeData(color: AppColors.textDarkPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgLight,
        selectedItemColor: AppColors.sageGreenDark,
        unselectedItemColor: AppColors.textDarkMuted,
      ),
    );
  }

  /// Figma Luxury Islamic Dark Theme
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.sageGreen,
      onPrimary: AppColors.bgDark,
      primaryContainer: AppColors.cardHighlight,
      onPrimaryContainer: AppColors.textWhite,
      secondary: AppColors.accentGold,
      onSecondary: AppColors.bgDark,
      surface: AppColors.cardDark,
      onSurface: AppColors.textWhite,
      error: AppColors.errorRed,
      outline: AppColors.borderGreen,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamilyAmiri,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgDark,
      cardColor: AppColors.cardDark,
      dividerColor: AppColors.borderGreen,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: AppDimensions.appBarHeight,
        titleTextStyle:
            AppTextStyles.appBarTitle.copyWith(color: AppColors.textWhite),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: const BorderSide(color: AppColors.borderGreen),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: AppColors.sageGreen,
        unselectedItemColor: AppColors.textDimmed,
      ),
    );
  }
}
