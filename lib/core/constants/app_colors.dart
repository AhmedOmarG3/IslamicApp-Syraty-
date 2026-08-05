import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary brand color
  static const Color primaryGreen = Color(0xFF004B40);
  static const Color kPrimaryColor = primaryGreen; // Backward compatibility

  // Secondary accent color
  static const Color secondaryGreen = Color(0xFF87D1A4);
  static const Color accentMint = Color(0xFF2C7865);
  static const Color darkTeal = Color(0xFF0F3930);

  // Card background accents
  static const Color cardQuranGreen = Color.fromARGB(255, 140, 204, 151);
  static const Color cardSebhaBlue = Color.fromARGB(255, 148, 216, 222);
  static const Color buttonCream = Color(0xFFFAF6EB);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
}
