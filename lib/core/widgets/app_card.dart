import 'package:flutter/material.dart';
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
    final cardPadding =
        padding ?? const EdgeInsets.all(AppDimensions.cardPadding);
    final cardMargin = margin ??
        const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
    final cardRadius = borderRadius ?? AppDimensions.radiusLg;
    final cardElevation = elevation ?? AppDimensions.elevationFlat;

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
        border: gradientColors == null
            ? Border.all(color: AppColors.outline)
            : null,
        boxShadow: cardElevation > 0
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: cardElevation * 2,
                  offset: Offset(0, cardElevation),
                )
              ]
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(cardRadius),
        child: onTap == null
            ? Padding(padding: cardPadding, child: child)
            : InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(cardRadius),
                child: Padding(padding: cardPadding, child: child),
              ),
      ),
    );
  }
}
