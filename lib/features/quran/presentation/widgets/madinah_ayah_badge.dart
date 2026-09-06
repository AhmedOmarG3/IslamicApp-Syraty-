import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

class MadinahAyahBadge extends StatelessWidget {
  final int ayahNumber;
  final double size;
  final Color borderColor;
  final Color textColor;
  final VoidCallback? onTap;

  const MadinahAyahBadge({
    super.key,
    required this.ayahNumber,
    this.size = 24.0,
    this.borderColor = AppColors.accentGold,
    this.textColor = AppColors.textDark,
    this.onTap,
  });

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? arabicDigits[d] : c;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(
      width: size.r,
      height: size.r,
      child: CustomPaint(
        painter: _MadinahRosettePainter(borderColor: borderColor),
        child: Center(
          child: Text(
            _toArabicDigits(ayahNumber),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: (size * 0.44).sp,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.1,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class _MadinahRosettePainter extends CustomPainter {
  final Color borderColor;

  const _MadinahRosettePainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // 1. Draw 8 outer circular rosette lobes (petals)
    final lobePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    const petals = 8;
    for (int i = 0; i < petals; i++) {
      final angle = i * 2 * pi / petals;
      final px = cx + (r * 0.72) * cos(angle);
      final py = cy + (r * 0.72) * sin(angle);
      canvas.drawCircle(Offset(px, py), r * 0.24, lobePaint);
    }

    // 2. Draw inner main bounding circle
    final circlePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(Offset(cx, cy), r * 0.75, circlePaint);

    // 3. Draw inner delicate fine ring
    final fineRingPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    canvas.drawCircle(Offset(cx, cy), r * 0.62, fineRingPaint);
  }

  @override
  bool shouldRepaint(covariant _MadinahRosettePainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
