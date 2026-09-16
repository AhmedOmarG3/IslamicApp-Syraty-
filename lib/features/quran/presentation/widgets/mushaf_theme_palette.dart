import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';

/// Reading paper themes for the Mushaf surface.
enum MushafThemeMode { cream, night, sepia }

/// Per-mode color palette for the Mushaf surface. Keeps the inline hex
/// colors that used to live in SurahPage in one testable place.
extension MushafThemePalette on MushafThemeMode {
  Color get scaffoldBackgroundColor {
    switch (this) {
      case MushafThemeMode.cream:
        return AppColors.bgLight; // Warm light ivory background
      case MushafThemeMode.night:
        return const Color(0xFF0D1110); // Deep sleek obsidian
      case MushafThemeMode.sepia:
        return const Color(0xFFEDE3D0); // Warm parchment
    }
  }

  Color get backgroundColor {
    switch (this) {
      case MushafThemeMode.cream:
        return AppColors.cardLight; // Clean warm ivory paper
      case MushafThemeMode.night:
        return const Color(0xFF131817);
      case MushafThemeMode.sepia:
        return const Color(0xFFF4EBD9);
    }
  }

  Color get textColor {
    switch (this) {
      case MushafThemeMode.cream:
        // Rich deep high-contrast Arabic calligraphy black-emerald
        return const Color(0xFF0F1813);
      case MushafThemeMode.night:
        // Crisp, pure, soft warm-white
        return const Color(0xFFF7F8F4);
      case MushafThemeMode.sepia:
        return const Color(0xFF281D10);
    }
  }

  Color get borderColor {
    switch (this) {
      case MushafThemeMode.cream:
        // Vibrant luxury Madinah gold
        return AppColors.accentGold;
      case MushafThemeMode.night:
        return const Color(0xFFC7A567);
      case MushafThemeMode.sepia:
        return const Color(0xFFA67C33);
    }
  }

  Color get headerCardColor {
    switch (this) {
      case MushafThemeMode.cream:
        return AppColors.cardLightElevated;
      case MushafThemeMode.night:
        return const Color(0xFF1C2421);
      case MushafThemeMode.sepia:
        return const Color(0xFFE6DAC0);
    }
  }
}
