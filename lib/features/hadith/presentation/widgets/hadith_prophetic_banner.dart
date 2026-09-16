import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/islamic_ornament_painter.dart';

class HadithPropheticBanner extends StatelessWidget {
  final bool isDark;

  const HadithPropheticBanner({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: IslamicOrnamentPainter(
          primaryGold: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.45),
          borderWidth: 1.0,
          cornerSize: 12.r,
          showCornerFlourishes: true,
          showInnerBorder: false,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_rounded, color: AppColors.accentGold, size: 18.r),
                  SizedBox(width: 6.w),
                  Text(
                    'رياض السنة النبوية المطهرة',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '«نَضَّرَ اللَّهُ امْرَأً سَمِعَ مَقَالَتِي فَوَعَاهَا وَحَفِظَهَا وَبَلَّغَهَا»',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15.sp,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'سنن الترمذي • حديث صحيح',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 10.5.sp,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
