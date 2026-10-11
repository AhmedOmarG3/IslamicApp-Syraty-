import 'dart:math';
import 'package:flutter/material.dart';

class IslamicStarBadge extends StatelessWidget {
  final double size;
  final Color color;
  final Widget? child;

  const IslamicStarBadge({
    super.key,
    this.size = 40,
    required this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _EightPointStarFillPainter(color: color),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _EightPointStarFillPainter extends CustomPainter {
  final Color color;

  const _EightPointStarFillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.62;

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
  bool shouldRepaint(covariant _EightPointStarFillPainter oldDelegate) =>
      oldDelegate.color != color;
}
