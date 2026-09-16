import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/hadith/data/services/hadith_service.dart';

class HadithChapterTile extends StatelessWidget {
  final HadithChapterInfo chapter;
  final bool isDark;
  final VoidCallback onTap;

  const HadithChapterTile({
    super.key,
    required this.chapter,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                // Chapter Icon Badge
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 16.r,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Chapter Name
                Expanded(
                  child: Text(
                    chapter.name,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    ),
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
