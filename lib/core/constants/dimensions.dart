import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppDimensions {
  // Border Radius Tokens
  static double get radiusSm => 8.r;
  static double get radiusMd => 16.r;
  static double get radiusLg => 24.r;
  static double get radiusPill => 100.r;

  // Elevation Tokens
  static double get elevationFlat => 0.0;
  static double get elevationLow => 2.0;
  static double get elevationMedium => 6.0;
  static double get elevationHigh => 12.0;

  // App Layout Dimensions
  static double get appBarHeight => 56.h;
  static double get buttonHeight => 50.h;
  static double get cardPadding => 16.w;
}
