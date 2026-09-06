import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IslamicPatternCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final Color? patternColor;
  final double patternOpacity;
  final double cellSize;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final bool showWatermarkCircles;
  final VoidCallback? onTap;

  const IslamicPatternCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.gradientBegin = Alignment.topRight,
    this.gradientEnd = Alignment.bottomLeft,
    this.patternColor,
    this.patternOpacity = 0.22,
    this.cellSize = 52.0,
    this.border,
    this.boxShadow,
    this.showWatermarkCircles = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(24.r);
    final effectiveGradient = gradientColors ??
        const [
          Color(0xFF1B4436),
          Color(0xFF133429),
          Color(0xFF0C1F17),
        ];

    // Vivid mint/sage emerald pattern color matching Islamic aesthetic
    final baseColor = patternColor ?? const Color(0xFF8DCFB8);
    final effectivePatternColor = baseColor.withValues(alpha: patternOpacity);

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: effectiveGradient,
        ),
        border: border ??
            Border.all(
              color: const Color(0xFF2B5443),
              width: 1.2,
            ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // 1. Islamic Tessellation Pattern Overlay
            Positioned.fill(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  strokeColor: effectivePatternColor,
                  cellSize: cellSize.r,
                  strokeWidth: 1.1,
                ),
              ),
            ),

            // 2. Concentric Watermark Rings in top corner
            if (showWatermarkCircles)
              Positioned.fill(
                child: CustomPaint(
                  painter: _WatermarkCirclesPainter(
                    color: const Color(0xFFC8A25A).withValues(alpha: 0.20),
                  ),
                ),
              ),

            // 3. Soft Radial Vignette for Depth
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    radius: 1.3,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.30),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Foreground Content
            Padding(
              padding: padding ?? EdgeInsets.all(18.r),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

class _WatermarkCirclesPainter extends CustomPainter {
  final Color color;

  const _WatermarkCirclesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric rings at the top-left (behind action pill)
    final center = Offset(size.width * 0.16, size.height * 0.22);
    canvas.drawCircle(center, 54.0, paint);
    canvas.drawCircle(center, 92.0, paint);
  }

  @override
  bool shouldRepaint(covariant _WatermarkCirclesPainter oldDelegate) =>
      oldDelegate.color != color;
}

class IslamicPatternPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final double cellSize;

  const IslamicPatternPainter({
    required this.strokeColor,
    this.strokeWidth = 1.1,
    this.cellSize = 52.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cols = (size.width / cellSize).ceil() + 1;
    final rows = (size.height / cellSize).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * cellSize + cellSize / 2;
        final cy = r * cellSize + cellSize / 2;

        _drawCell(canvas, cx, cy, cellSize, paint);
      }
    }
  }

  void _drawCell(Canvas canvas, double cx, double cy, double s, Paint paint) {
    // 1. Surrounding square grid line
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: s, height: s),
      paint,
    );

    // 2. Interlocking Octagram (8-pointed star)
    final outerRadius = s * 0.44;
    final innerRadius = s * 0.31;

    final starPath = Path();
    for (int i = 0; i < 16; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / 8) - (pi / 2);
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, paint);

    // 3. Center Circle
    canvas.drawCircle(Offset(cx, cy), s * 0.12, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.strokeWidth != strokeWidth;
}
