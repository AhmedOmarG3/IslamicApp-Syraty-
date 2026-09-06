import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';

class HomeSectionsGrid extends StatelessWidget {
  const HomeSectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 1. Full Width Quran Banner Tile
        GestureDetector(
          onTap: () => context.go('/quran'),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    'القرآن الكريم',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // 2. Row of Two Tiles: Hisn Al-Muslim & Prayer Times
        Row(
          children: [
            Expanded(
              child: _buildGridTile(
                context: context,
                icon: Icons.article_outlined,
                title: 'حصن المسلم',
                onTap: () => context.push('/hisn-al-muslim'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGridTile(
                context: context,
                icon: Icons.access_time_rounded,
                title: 'مواقيت الصلاة',
                onTap: () => context.go('/prayer'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // 3. Row of Two Tiles: Favorites & Zakat
        Row(
          children: [
            Expanded(
              child: _buildGridTile(
                context: context,
                icon: Icons.bookmark_border_rounded,
                title: 'المفضلة\nوملاحظاتي',
                onTap: () => context.push('/favorites'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGridTile(
                context: context,
                icon: Icons.monetization_on_outlined,
                title: 'حاسبة الزكاة',
                onTap: () => context.push('/zakat'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                size: 20.r,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
