import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Authentic handcrafted Islamic geometric ornament and border painter.
/// Provides traditional Madinah Mushaf-inspired double gold borders,
/// corner arabesque flourishes, 8-pointed star rosettes, and Mihrab arches.
class IslamicOrnamentPainter extends CustomPainter {
  final Color primaryGold;
  final Color? secondaryAccent;
  final double borderWidth;
  final double cornerSize;
  final bool showCornerFlourishes;
  final bool showInnerBorder;
  final bool showArch;

  const IslamicOrnamentPainter({
    this.primaryGold = const Color(0xFFD4AF37),
    this.secondaryAccent,
    this.borderWidth = 1.2,
    this.cornerSize = 22.0,
    this.showCornerFlourishes = true,
    this.showInnerBorder = true,
    this.showArch = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = primaryGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true;

    final subtleGoldPaint = Paint()
      ..color = primaryGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 0.7
      ..isAntiAlias = true;

    final accentPaint = Paint()
      ..color = (secondaryAccent ?? primaryGold).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    const outerMargin = 4.0;
    final outerRect = Rect.fromLTWH(
      outerMargin,
      outerMargin,
      size.width - outerMargin * 2,
      size.height - outerMargin * 2,
    );

    // 1. Draw outer boundary with slightly softened corners
    final rrect = RRect.fromRectAndRadius(outerRect, const Radius.circular(16));
    canvas.drawRRect(rrect, goldPaint);

    // 2. Draw inner border (traditional Mushaf frame)
    if (showInnerBorder) {
      const innerMargin = 10.0;
      final innerRect = Rect.fromLTWH(
        innerMargin,
        innerMargin,
        size.width - innerMargin * 2,
        size.height - innerMargin * 2,
      );
      final innerRRect = RRect.fromRectAndRadius(innerRect, const Radius.circular(10));
      canvas.drawRRect(innerRRect, subtleGoldPaint);
    }

    // 3. Draw Corner Arabesques (authentic floral-geometric corner cartouches)
    if (showCornerFlourishes) {
      _drawCornerFlourish(canvas, const Offset(outerMargin + 4, outerMargin + 4), 0, goldPaint, accentPaint);
      _drawCornerFlourish(canvas, Offset(size.width - outerMargin - 4, outerMargin + 4), math.pi / 2, goldPaint, accentPaint);
      _drawCornerFlourish(canvas, Offset(size.width - outerMargin - 4, size.height - outerMargin - 4), math.pi, goldPaint, accentPaint);
      _drawCornerFlourish(canvas, Offset(outerMargin + 4, size.height - outerMargin - 4), 3 * math.pi / 2, goldPaint, accentPaint);
    }

    // 4. Draw Mihrab Arch Top silhouette if enabled
    if (showArch) {
      _drawMihrabArch(canvas, size, goldPaint, subtleGoldPaint);
    }
  }

  void _drawCornerFlourish(
    Canvas canvas,
    Offset origin,
    double angle,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final path = Path();
    // Intricate geometric quadrant corner bracket
    path.moveTo(0, 0);
    path.lineTo(cornerSize, 0);
    path.lineTo(cornerSize * 0.75, cornerSize * 0.25);
    path.lineTo(cornerSize * 0.25, cornerSize * 0.25);
    path.lineTo(cornerSize * 0.25, cornerSize * 0.75);
    path.lineTo(0, cornerSize);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Small golden corner square (تربيعة زاوية مذهبة)
    final squarePaint = Paint()
      ..color = primaryGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cornerSize * 0.35, cornerSize * 0.35), 1.6, squarePaint);

    canvas.restore();
  }

  void _drawMihrabArch(Canvas canvas, Size size, Paint strokePaint, Paint subtlePaint) {
    final archWidth = math.min(size.width * 0.65, 240.0);
    final left = (size.width - archWidth) / 2;
    final right = left + archWidth;
    const top = 12.0;
    const archHeight = 22.0;

    final archPath = Path();
    archPath.moveTo(left, top + archHeight);
    // Pointed Islamic arch cusp
    archPath.quadraticBezierTo(
      left + archWidth * 0.25,
      top + 4,
      size.width / 2,
      top,
    );
    archPath.quadraticBezierTo(
      right - archWidth * 0.25,
      top + 4,
      right,
      top + archHeight,
    );

    canvas.drawPath(archPath, strokePaint);

    // Draw central arch crown star
    _drawEightPointStar(canvas, Offset(size.width / 2, top - 3), 4.5, strokePaint);
  }

  static void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final fillPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    // Draw two overlapping squares rotated 45 degrees (Khattam Sulayman)
    for (int i = 0; i < 2; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 4);
      final r = Rect.fromCenter(center: Offset.zero, width: radius * 1.5, height: radius * 1.5);
      canvas.drawRect(r, fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant IslamicOrnamentPainter oldDelegate) {
    return oldDelegate.primaryGold != primaryGold ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.showArch != showArch ||
        oldDelegate.showCornerFlourishes != showCornerFlourishes;
  }
}

/// A luxury widget container that wraps its child with the authentic Islamic border.
class IslamicOrnamentFrame extends StatelessWidget {
  final Widget child;
  final Color primaryGold;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final EdgeInsetsGeometry padding;
  final bool showArch;
  final bool showCorners;
  final double cornerSize;
  final double borderWidth;
  final BorderRadius? borderRadius;

  const IslamicOrnamentFrame({
    super.key,
    required this.child,
    this.primaryGold = const Color(0xFFD4AF37),
    this.backgroundColor,
    this.backgroundGradient,
    this.padding = const EdgeInsets.all(16.0),
    this.showArch = false,
    this.showCorners = true,
    this.cornerSize = 20.0,
    this.borderWidth = 1.2,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomPaint(
        painter: IslamicOrnamentPainter(
          primaryGold: primaryGold,
          borderWidth: borderWidth,
          cornerSize: cornerSize,
          showCornerFlourishes: showCorners,
          showArch: showArch,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// An ornamental divider with a centered 8-pointed star rosette.
class IslamicRosetteDivider extends StatelessWidget {
  final Color goldColor;
  final double height;

  const IslamicRosetteDivider({
    super.key,
    this.goldColor = const Color(0xFFD4AF37),
    this.height = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.05),
                    goldColor.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 8, color: goldColor.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                CustomPaint(
                  size: const Size(14, 14),
                  painter: _RosetteStarPainter(goldColor),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star_rounded, size: 8, color: goldColor.withValues(alpha: 0.6)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.65),
                    goldColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RosetteStarPainter extends CustomPainter {
  final Color color;
  const _RosetteStarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 2; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 4);
      final r = Rect.fromCenter(center: Offset.zero, width: radius * 1.4, height: radius * 1.4);
      canvas.drawRect(r, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RosetteStarPainter oldDelegate) => oldDelegate.color != color;
}
