import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppSpacing {
  static double get xxs => 2.0.w;
  static double get xs => 4.0.w;
  static double get sm => 8.0.w;
  static double get md => 16.0.w;
  static double get lg => 24.0.w;
  static double get xl => 32.0.w;
  static double get xxl => 48.0.w;

  // Pre-configured Vertical Spacers
  static SizedBox get verticalXs => SizedBox(height: 4.0.h);
  static SizedBox get verticalSm => SizedBox(height: 8.0.h);
  static SizedBox get verticalMd => SizedBox(height: 16.0.h);
  static SizedBox get verticalLg => SizedBox(height: 24.0.h);
  static SizedBox get verticalXl => SizedBox(height: 32.0.h);

  // Pre-configured Horizontal Spacers
  static SizedBox get horizontalXs => SizedBox(width: 4.0.w);
  static SizedBox get horizontalSm => SizedBox(width: 8.0.w);
  static SizedBox get horizontalMd => SizedBox(width: 16.0.w);
  static SizedBox get horizontalLg => SizedBox(width: 24.0.w);
}
