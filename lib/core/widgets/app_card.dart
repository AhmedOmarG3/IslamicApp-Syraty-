import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradientColors,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ?? EdgeInsets.all(AppDimensions.cardPadding);
    final cardMargin = margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
    final cardRadius = borderRadius ?? AppDimensions.radiusLg;
    final cardElevation = elevation ?? AppDimensions.elevationLow;

    return Container(
      margin: cardMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        color: gradientColors == null
            ? (backgroundColor ?? AppColors.cardSurface)
            : null,
        boxShadow: cardElevation > 0
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: cardElevation * 2,
                  offset: Offset(0, cardElevation),
                )
              ]
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Padding(
            padding: cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}
