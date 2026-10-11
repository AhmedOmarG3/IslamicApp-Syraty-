import 'dart:math';
import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';

class OrnamentDivider extends StatelessWidget {
  final double starSize;
  final Color? starColor;
  final Color? lineColor;
  final double verticalPadding;

  const OrnamentDivider({
    super.key,
    this.starSize = 18,
    this.starColor,
    this.lineColor,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveStarColor = starColor ?? AppColors.accentGold;
    final effectiveLineColor =
        lineColor ?? (isDark ? AppColors.borderSubtle : AppColors.borderLight);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    effectiveLineColor,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomPaint(
              size: Size(starSize, starSize),
              painter: _EightPointStarPainter(color: effectiveStarColor),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveLineColor,
                    Colors.transparent,
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

class _EightPointStarPainter extends CustomPainter {
  final Color color;

  const _EightPointStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.58;

    final path = Path();
    for (int i = 0; i < 16; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / 8) - (pi / 2);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Inner dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius * 0.18, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _EightPointStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
