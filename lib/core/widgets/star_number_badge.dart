import 'dart:math';
import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';

class StarNumberBadge extends StatelessWidget {
  final String number;
  final double size;
  final Color? outlineColor;
  final Color? textColor;
  final Color? fillColor;

  const StarNumberBadge({
    super.key,
    required this.number,
    this.size = 42,
    this.outlineColor,
    this.textColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOutline = outlineColor ?? AppColors.borderGreen;
    final effectiveText = textColor ?? AppColors.sageGreen;
    final effectiveFill =
        fillColor ?? AppColors.cardDarkElevated.withValues(alpha: 0.5);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _IslamicOctagramPainter(
              outlineColor: effectiveOutline,
              fillColor: effectiveFill,
            ),
          ),
          Text(
            number,
            style: AppTextStyles.caption.copyWith(
              color: effectiveText,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.36,
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicOctagramPainter extends CustomPainter {
  final Color outlineColor;
  final Color fillColor;

  const _IslamicOctagramPainter({
    required this.outlineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;
    final innerRadius = outerRadius * 0.72;

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

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _IslamicOctagramPainter oldDelegate) =>
      oldDelegate.outlineColor != outlineColor ||
      oldDelegate.fillColor != fillColor;
}
