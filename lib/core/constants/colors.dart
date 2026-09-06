import 'package:flutter/material.dart';

abstract class AppColors {
  // === Figma Luxury Islamic Dark Palette ===
  // Backgrounds
  static const Color bgDark = Color(0xFF0C1A16);
  static const Color bgDarkGradientTop = Color(0xFF142B23);
  static const Color bgDarkGradientBottom = Color(0xFF0C1A16);
  static const Color scaffoldBackground = bgDark;

  // === Figma Luxury Islamic Light Palette ===
  static const Color bgLight = Color(0xFFF9F6EE); // Warm ivory background from screenshot
  static const Color cardLight = Color(0xFFFFFDF9); // Clean warm white card surface
  static const Color cardLightElevated = Color(0xFFF4ECE1); // Slightly elevated beige card
  static const Color borderLight = Color(0xFFEADBCE); // Subtle warm gold-beige border
  static const Color navPillActiveLight = Color(0xFFEFE7D8); // Navigation active tab pill
  static const Color iconBgCircleLight = Color(0xFFF0EADB); // Feature icon background circle
  static const Color textDarkPrimary = Color(0xFF1E2824); // Primary text in light mode
  static const Color textDarkMuted = Color(0xFF6C7D75); // Muted text in light mode

  // Card Surfaces
  static const Color cardDark = Color(0xFF142923);
  static const Color cardDarkElevated = Color(0xFF18332C);
  static const Color cardHighlight = Color(0xFF1F3D35);
  static const Color cardActiveGreen = Color(0xFF24483E);

  // Accents
  static const Color sageGreen = Color(0xFF6FA593);
  static const Color sageGreenLight = Color(0xFF90B8AB);
  static const Color sageGreenDark = Color(0xFF477A6A);
  static const Color sageGreenContainer = Color(0xFF1C3830);

  static const Color accentGold = Color(0xFFC8A25A);
  static const Color accentGoldLight = Color(0xFFE2C482);
  static const Color accentGoldSoft = Color(0x33C8A25A);

  // Parchment paper for Quran reading card
  static const Color parchmentPaper = Color(0xFFFAF7EE);
  static const Color parchmentPaperDark = Color(0xFFF0EADB);

  // Borders & Outlines
  static const Color borderSubtle = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.10)
  static const Color borderGreen = Color(0xFF22443B);
  static const Color borderGold = Color(0xFFC8A25A);

  // Typography
  static const Color textWhite = Color(0xFFF4F8F6);
  static const Color textMuted = Color(0xFF98ACA4);
  static const Color textDimmed = Color(0xFF6C8078);
  static const Color textGold = Color(0xFFC8A25A);
  static const Color textDark = Color(0xFF1E2824);

  // Aliases for backward compatibility
  static const Color primaryGreen = sageGreen;
  static const Color primaryDark = Color(0xFF0C1A16);
  static const Color darkTeal = bgDark;
  static const Color secondaryGreen = sageGreenDark;
  static const Color accentMint = sageGreenLight;

  static const Color surfaceLight = bgDark;
  static const Color surfaceDark = bgDark;
  static const Color cardSurface = cardDark;
  static const Color surfaceContainer = cardDarkElevated;
  static const Color surfacePressed = cardHighlight;
  static const Color outline = borderGreen;

  static const Color textPrimary = textWhite;
  static const Color textSecondary = textMuted;

  // Feature Card Backgrounds
  static const Color cardQuranGreen = sageGreen;
  static const Color cardSebhaBlue = Color(0xFF5E9C9E);
  static const Color buttonCream = parchmentPaper;

  // Status Colors
  static const Color errorRed = Color(0xFFE57373);
  static const Color warningOrange = Color(0xFFFFB74D);
  static const Color successGreen = Color(0xFF81C784);

  // Standard Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color grey = Colors.grey;
  static const Color transparent = Colors.transparent;

  static const Color kPrimaryColor = primaryGreen;
}
