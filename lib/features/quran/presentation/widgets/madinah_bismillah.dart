import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

class MadinahBismillah extends StatelessWidget {
  final Color textColor;
  final Color ornamentColor;

  const MadinahBismillah({
    super.key,
    this.textColor = AppColors.textDark,
    this.ornamentColor = AppColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Right ornamental wing
            Icon(
              Icons.flare_rounded,
              size: 13.r,
              color: ornamentColor.withValues(alpha: 0.7),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 32.w,
              height: 1.0,
              color: ornamentColor.withValues(alpha: 0.5),
            ),
            SizedBox(width: 12.w),

            // Central Calligraphic Basmala
            Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 21.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.4,
              ),
            ),

            // Left ornamental wing
            SizedBox(width: 12.w),
            Container(
              width: 32.w,
              height: 1.0,
              color: ornamentColor.withValues(alpha: 0.5),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.flare_rounded,
              size: 13.r,
              color: ornamentColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
