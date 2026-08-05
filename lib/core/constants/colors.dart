import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Palette - Minimal Islamic Emerald & Gold
  static const Color primaryGreen = Color(0xFF004B40);
  static const Color primaryDark = Color(0xFF0F3930);
  static const Color darkTeal = primaryDark;
  static const Color secondaryGreen = Color(0xFF2C7865);
  static const Color accentMint = Color(0xFF87D1A4);
  static const Color accentGold = Color(0xFFD4AF37);

  // Surface & Neutral Colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1D242B);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Feature Card Backgrounds
  static const Color cardQuranGreen = Color(0xFF8CCC97);
  static const Color cardSebhaBlue = Color(0xFF94D8DE);
  static const Color buttonCream = Color(0xFFFAF6EB);

  // Status & State Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color successGreen = Color(0xFF388E3C);

  // Standard Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color grey = Colors.grey;
  static const Color transparent = Colors.transparent;

  // Backward compatibility alias
  static const Color kPrimaryColor = primaryGreen;
}
