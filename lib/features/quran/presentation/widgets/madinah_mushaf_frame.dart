import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

/// Authentic double-line gold border with corner arabesques,
/// replicating the King Fahd Complex Madinah Mushaf page layout.
class MadinahMushafFrame extends StatelessWidget {
  final Widget child;
  final String surahName;
  final String juzName;
  final int? pageNumber;
  final Color backgroundColor;
  final Color borderColor;
  final Color headerTextColor;
  final bool isFullScreen;
  final double? minHeight;

  const MadinahMushafFrame({
    super.key,
    required this.child,
    required this.surahName,
    required this.juzName,
    this.pageNumber,
    this.backgroundColor = AppColors.parchmentPaper,
    this.borderColor = AppColors.accentGold,
    this.headerTextColor = AppColors.textDark,
    this.isFullScreen = false,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final framePadding = isFullScreen
        ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h)
        : EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h);

    final contentPadding = isFullScreen
        ? EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h)
        : EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h);

    return Container(
      width: double.infinity,
      constraints:
          minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isFullScreen ? 10.r : 16.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: isFullScreen ? 0.20 : 0.35)
                : AppColors.accentGold.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _MadinahFramePainter(
          borderColor: borderColor,
          isCompact: isFullScreen,
        ),
        child: Padding(
          padding: framePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Band (Surah Name & Juz)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Surah Name on right
                        Flexible(
                          child: Text(
                            'سُورَةُ $surahName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                            ),
                          ),
                        ),

                        // Central small 8-pointed star ornament
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Icon(
                            Icons.flare_rounded,
                            size: 13.r,
                            color: borderColor.withValues(alpha: 0.85),
                          ),
                        ),

                        // Juz Name on left
                        Flexible(
                          child: Text(
                            juzName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Thin divider beneath top header band
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Container(
                      height: 0.8,
                      color: borderColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),

              // Middle Mushaf Content (Surah Banner, Bismillah, Verses)
              if (minHeight != null)
                Expanded(
                  child: Padding(
                    padding: contentPadding,
                    child: child,
                  ),
                )
              else
                Padding(
                  padding: contentPadding,
                  child: child,
                ),

              // Bottom Footer Section (with Authentic Madinah Page Number)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Container(
                      height: 0.8,
                      color: borderColor.withValues(alpha: 0.4),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.spa_rounded,
                        size: 10.r,
                        color: borderColor.withValues(alpha: 0.65),
                      ),
                      SizedBox(width: 8.w),
                      if (pageNumber != null)
                        Text(
                          QuranMetadata.toArabicDigits(pageNumber!),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: borderColor,
                            height: 1.15,
                          ),
                        )
                      else
                        Icon(
                          Icons.spa_rounded,
                          size: 12.r,
                          color: borderColor.withValues(alpha: 0.8),
                        ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.spa_rounded,
                        size: 10.r,
                        color: borderColor.withValues(alpha: 0.65),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MadinahFramePainter extends CustomPainter {
  final Color borderColor;
  final bool isCompact;

  const _MadinahFramePainter({
    required this.borderColor,
    this.isCompact = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final innerPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final outerMargin = isCompact ? 3.0 : 4.5;
    final innerMargin = isCompact ? 6.0 : 8.0;

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        outerMargin,
        outerMargin,
        size.width - outerMargin * 2,
        size.height - outerMargin * 2,
      ),
      Radius.circular(isCompact ? 8 : 12),
    );

    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        innerMargin,
        innerMargin,
        size.width - innerMargin * 2,
        size.height - innerMargin * 2,
      ),
      Radius.circular(isCompact ? 5 : 8),
    );

    canvas.drawRRect(outerRect, outerPaint);
    canvas.drawRRect(innerRect, innerPaint);

    // Draw Islamic 8-pointed corner stars
    final starOffset = outerMargin + 3.0;
    _drawCornerStar(canvas, starOffset, starOffset, borderColor);
    _drawCornerStar(canvas, size.width - starOffset, starOffset, borderColor);
    _drawCornerStar(canvas, starOffset, size.height - starOffset, borderColor);
    _drawCornerStar(
        canvas, size.width - starOffset, size.height - starOffset, borderColor);
  }

  void _drawCornerStar(Canvas canvas, double cx, double cy, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final r1 = isCompact ? 2.8 : 3.5;
    final r2 = isCompact ? 1.5 : 2.0;
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final r = i.isEven ? r1 : r2;
      final angle = i * pi / 8;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MadinahFramePainter oldDelegate) =>
      oldDelegate.borderColor != borderColor ||
      oldDelegate.isCompact != isCompact;
}
