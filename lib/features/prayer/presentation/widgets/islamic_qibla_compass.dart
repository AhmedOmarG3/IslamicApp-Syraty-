import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class IslamicQiblaCompass extends StatelessWidget {
  final double heading;
  final double qiblaBearing;
  final bool isAligned;
  final double size;

  const IslamicQiblaCompass({
    super.key,
    required this.heading,
    required this.qiblaBearing,
    required this.isAligned,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Needle points towards (qiblaBearing - heading)
    var relativeDeg = (qiblaBearing - heading) % 360;
    if (relativeDeg < 0) relativeDeg += 360;
    final needleAngleRad = relativeDeg * (math.pi / 180);

    return SizedBox(
      width: size.r,
      height: size.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Outer Glow when Aligned (Emerald in daylight for high contrast, Gold in dark mode)
          if (isAligned)
            Container(
              width: size.r,
              height: size.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.accentGold.withValues(alpha: 0.45)
                        : const Color(0xFF1E6B52).withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),

          // 2. Rotating Astrolabe Compass Dial (Rotates against heading so North stays True North)
          Transform.rotate(
            angle: -(heading * (math.pi / 180)),
            child: SizedBox(
              width: size.r,
              height: size.r,
              child: CustomPaint(
                painter: _AstrolabeDialPainter(
                  isDark: isDark,
                  isAligned: isAligned,
                ),
              ),
            ),
          ),

          // 3. Central Islamic Medallion Background
          Container(
            width: (size * 0.48).r,
            height: (size * 0.48).r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1B4235),
                        const Color(0xFF0F2B22),
                        const Color(0xFF071712),
                      ]
                    : [
                        const Color(0xFFFAF4E8),
                        const Color(0xFFF1E6D0),
                        const Color(0xFFDFCEB0),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isAligned ? AppColors.accentGold : const Color(0xFFC7A567).withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: isDark ? 0.25 : 0.35,
                child: Icon(
                  Icons.explore_rounded,
                  size: (size * 0.22).r,
                  color: AppColors.accentGold,
                ),
              ),
            ),
          ),

          // 4. Direction Needle pointing to Kaaba
          Transform.rotate(
            angle: needleAngleRad,
            child: SizedBox(
              width: size.r,
              height: size.r,
              child: CustomPaint(
                painter: _QiblaNeedlePainter(
                  isAligned: isAligned,
                ),
              ),
            ),
          ),

          // 5. Center Metallic Pivot Dome
          Container(
            width: 26.r,
            height: 26.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [
                  Color(0xFFFFF0CA),
                  Color(0xFFE5C78A),
                  Color(0xFF9E7B34),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF6B501B),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 7.r,
                height: 7.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF141C18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for the ornate Islamic Astrolabe dial
class _AstrolabeDialPainter extends CustomPainter {
  final bool isDark;
  final bool isAligned;

  const _AstrolabeDialPainter({
    required this.isDark,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Outer Brass Rim Background
    final rimPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFF143026),
                const Color(0xFF0D211A),
                const Color(0xFF081510),
              ]
            : [
                const Color(0xFFF9F4E9),
                const Color(0xFFEDE1CA),
                const Color(0xFFDECBAE),
              ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, rimPaint);

    // 2. Outer Border Rings
    final goldBorder = Paint()
      ..color = isAligned
          ? (isDark ? const Color(0xFFFFDF88) : const Color(0xFF1E6B52))
          : (isDark ? const Color(0xFFC7A567) : const Color(0xFF9E7B34))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 3.0 : 2.0;
    canvas.drawCircle(center, radius - 2, goldBorder);

    // Luminous inner emerald ring when aligned
    if (isAligned) {
      final greenRing = Paint()
        ..color = (isDark ? const Color(0xFF4CAF50) : const Color(0xFF1E6B52))
            .withValues(alpha: isDark ? 0.35 : 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(center, radius - 7, greenRing);
    }

    final innerBorder = Paint()
      ..color = isDark
          ? const Color(0xFFC7A567).withValues(alpha: 0.4)
          : const Color(0xFF8A6624).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 18, innerBorder);

    // 3. Degree Tick Marks (360 degrees)
    final majorTickPaint = Paint()
      ..color = isAligned
          ? (isDark ? const Color(0xFFFFE7A8) : const Color(0xFF1E6B52))
          : (isDark ? const Color(0xFFD6BE97) : const Color(0xFF6B4F1B))
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = const Color(0xFFC7A567).withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 360; i += 5) {
      final angle = (i * math.pi) / 180;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final startR = radius - 4;
      final endR = isCardinal
          ? radius - 16
          : (isMajor ? radius - 13 : radius - 9);

      final p1 = Offset(
        center.dx + startR * math.cos(angle),
        center.dy + startR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + endR * math.cos(angle),
        center.dy + endR * math.sin(angle),
      );

      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : minorTickPaint);
    }

    // 4. Islamic 8-Point Star in the Middle Track
    _drawIslamicStar(canvas, center, radius * 0.72);

    // 5. Cardinal Direction Labels (ش = North, ق = East, ج = South, غ = West)
    _drawCardinalLabels(canvas, center, radius - 28);
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double r) {
    final starPaint = Paint()
      ..color = const Color(0xFFC7A567).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // First Square
    final path1 = Path();
    for (int i = 0; i < 4; i++) {
      final a = (i * 90) * math.pi / 180;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) {
        path1.moveTo(p.dx, p.dy);
      } else {
        path1.lineTo(p.dx, p.dy);
      }
    }
    path1.close();
    canvas.drawPath(path1, starPaint);

    // Second Square (Rotated 45 degrees)
    final path2 = Path();
    for (int i = 0; i < 4; i++) {
      final a = (i * 90 + 45) * math.pi / 180;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) {
        path2.moveTo(p.dx, p.dy);
      } else {
        path2.lineTo(p.dx, p.dy);
      }
    }
    path2.close();
    canvas.drawPath(path2, starPaint);
  }

  void _drawCardinalLabels(Canvas canvas, Offset center, double r) {
    final cardinalColor = isDark
        ? const Color(0xFFC7A567)
        : const Color(0xFF38270E); // High-contrast dark bronze for daylight visibility
    final labels = [
      {'text': 'ش', 'angle': -90.0, 'color': Colors.redAccent},
      {'text': 'ق', 'angle': 0.0, 'color': cardinalColor},
      {'text': 'ج', 'angle': 90.0, 'color': cardinalColor},
      {'text': 'غ', 'angle': 180.0, 'color': cardinalColor},
    ];

    for (final l in labels) {
      final a = (l['angle'] as double) * math.pi / 180;
      final pos = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));

      final textSpan = TextSpan(
        text: l['text'] as String,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: l['color'] as Color,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AstrolabeDialPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.isAligned != isAligned;
  }
}

/// CustomPainter for the Islamic Qibla Needle pointing directly to Makkah
class _QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;

  const _QiblaNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final topY = size.height * 0.07; // Tip of needle
    final bottomY = size.height * 0.78; // Tail of needle

    // 1. Gold Chiseled Sword Needle (North / Qibla side)
    // Left Half (Highlighted Gold)
    final leftPath = Path()
      ..moveTo(center.dx, topY)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();

    final leftPaint = Paint()
      ..shader = LinearGradient(
        colors: isAligned
            ? [const Color(0xFFFFF2D0), const Color(0xFFE5C78A)]
            : [const Color(0xFFE5C78A), const Color(0xFFC7A567)],
      ).createShader(Rect.fromPoints(Offset(center.dx, topY), center));
    canvas.drawPath(leftPath, leftPaint);

    // Right Half (Deep Bronzed Gold)
    final rightPath = Path()
      ..moveTo(center.dx, topY)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();

    final rightPaint = Paint()
      ..shader = LinearGradient(
        colors: isAligned
            ? [const Color(0xFFE5C78A), const Color(0xFF9E7B34)]
            : [const Color(0xFFB58F49), const Color(0xFF755520)],
      ).createShader(Rect.fromPoints(Offset(center.dx, topY), center));
    canvas.drawPath(rightPath, rightPaint);

    // 2. Opposite Counter-balance Tail
    final tailPath = Path()
      ..moveTo(center.dx - 5, center.dy)
      ..lineTo(center.dx, bottomY)
      ..lineTo(center.dx + 5, center.dy)
      ..close();

    final tailPaint = Paint()
      ..color = const Color(0xFF4A3A22).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tailPath, tailPaint);

    // 3. Kaaba Medallion at the tip
    final kaabaCenter = Offset(center.dx, topY + 4);

    // Radiant halo when aligned
    if (isAligned) {
      final haloPaint = Paint()
        ..color = const Color(0xFF1E6B52).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(kaabaCenter, 19, haloPaint);
    }

    final kaabaBgPaint = Paint()
      ..color = isAligned ? const Color(0xFF1E6B52) : const Color(0xFF182E25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(kaabaCenter, 14, kaabaBgPaint);

    final kaabaBorder = Paint()
      ..color = isAligned ? const Color(0xFFFFD54F) : const Color(0xFFE5C78A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 2.5 : 1.8;
    canvas.drawCircle(kaabaCenter, 14, kaabaBorder);

    // Kaaba Miniature Cube Icon
    final cubePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final cubeRect = Rect.fromCenter(center: kaabaCenter, width: 14, height: 14);
    canvas.drawRRect(RRect.fromRectAndRadius(cubeRect, const Radius.circular(2)), cubePaint);

    // Kaaba Kiswa Gold Band
    final kiswaGold = Paint()
      ..color = const Color(0xFFFFDF88)
      ..strokeWidth = 1.6;
    canvas.drawLine(
      Offset(cubeRect.left, cubeRect.top + 4),
      Offset(cubeRect.right, cubeRect.top + 4),
      kiswaGold,
    );
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
