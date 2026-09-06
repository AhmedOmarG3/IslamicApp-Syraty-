import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

/// The iconic Surah Header Banner (ترويسة السورة) from the King Fahd Madinah Mushaf.
class MadinahSurahHeader extends StatelessWidget {
  final String surahName;
  final bool isMakki;
  final int versesCount;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const MadinahSurahHeader({
    super.key,
    required this.surahName,
    required this.isMakki,
    required this.versesCount,
    this.borderColor = AppColors.accentGold,
    this.backgroundColor = AppColors.parchmentPaperDark,
    this.textColor = AppColors.textDark,
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
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.85),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SurahHeaderBannerPainter(borderColor: borderColor),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Right Wing: Makkiyah or Madaniyah
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isMakki ? 'مَكِّيَّة' : 'مَدَنِيَّة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
              ),

              // 2. Central Ornamental Cartouche: Surah Name
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: borderColor.withValues(alpha: 0.7),
                        width: 1.0,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'سُورَةُ $surahName',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Left Wing: Number of Verses
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'آيَاتُهَا ${_toArabicDigits(versesCount)}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurahHeaderBannerPainter extends CustomPainter {
  final Color borderColor;

  const _SurahHeaderBannerPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Corner decorative brackets
    const bracketSize = 8.0;
    // Top-left
    canvas.drawLine(const Offset(4, 4), const Offset(4 + bracketSize, 4), paint);
    canvas.drawLine(const Offset(4, 4), const Offset(4, 4 + bracketSize), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width - 4 - bracketSize, 4), paint);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width - 4, 4 + bracketSize), paint);
    // Bottom-left
    canvas.drawLine(Offset(4, size.height - 4), Offset(4 + bracketSize, size.height - 4), paint);
    canvas.drawLine(Offset(4, size.height - 4), Offset(4, size.height - 4 - bracketSize), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - 4, size.height - 4), Offset(size.width - 4 - bracketSize, size.height - 4), paint);
    canvas.drawLine(Offset(size.width - 4, size.height - 4), Offset(size.width - 4, size.height - 4 - bracketSize), paint);
  }

  @override
  bool shouldRepaint(covariant _SurahHeaderBannerPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
