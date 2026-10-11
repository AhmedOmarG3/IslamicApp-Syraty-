import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/services/favorites_service.dart';
import 'package:siraty/features/hadith/data/models/hadith_model.dart';

/// Lightweight, modern, calm Islamic card displaying a Hadith with crystal-clear typography.
class HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool isDark;
  final VoidCallback onToggleFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.isDark,
    required this.onToggleFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final favId = '${hadith.book}_${hadith.id}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Category / Chapter Badge + Book Source Pill
            Row(
              children: [
                // Chapter / Topic Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold
                        .withValues(alpha: isDark ? 0.14 : 0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 13.r,
                        color: AppColors.accentGold,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        hadith.chapter.isNotEmpty
                            ? hadith.chapter
                            : hadith.book,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.accentGoldLight
                              : AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Source Reference Pill
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardHighlight
                        : const Color(0xFFF1EFEA),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    hadith.book,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textDimmed
                          : AppColors.textDarkMuted,
                    ),
                  ),
                ),
              ],
            ),

            // Narrator if present
            if (hadith.narrator.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                'عن ${hadith.narrator}:',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                ),
              ),
            ],

            SizedBox(height: 8.h),

            // Arabic Matn (Hadith Text) - Spacious, clear, untangled modern Arabic typography
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.bgDark.withValues(alpha: 0.45)
                    : const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border(
                  right: BorderSide(
                    color: AppColors.accentGold.withValues(alpha: 0.70),
                    width: 3.w,
                  ),
                ),
              ),
              child: SelectableText(
                hadith.arabic,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.9,
                  letterSpacing: 0.15,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark ? AppColors.textWhite : const Color(0xFF1B2621),
                ),
              ),
            ),

            // Explanation / Benefit if available
            if (hadith.explanation.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 15.r,
                      color: AppColors.accentGold,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        hadith.explanation,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.6,
                          color: isDark
                              ? AppColors.textWhite.withValues(alpha: 0.85)
                              : AppColors.textDarkPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),

            // Action Buttons: Favorite, Copy, Share Card
            ListenableBuilder(
              listenable: FavoritesService.instance,
              builder: (context, _) {
                final isFav = FavoritesService.instance.items.any(
                  (e) =>
                      (e.id == favId || e.id == hadith.id.toString()) &&
                      e.type == FavoriteType.hadith,
                );
                return Row(
                  children: [
                    HadithActionButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      label: isFav ? 'محفوظ' : 'حفظ',
                      iconColor: isFav
                          ? Colors.redAccent
                          : (isDark
                              ? AppColors.accentGoldLight
                              : AppColors.accentGold),
                      onTap: onToggleFavorite,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    HadithActionButton(
                      icon: Icons.copy_rounded,
                      label: 'نسخ',
                      onTap: onCopy,
                      isDark: isDark,
                    ),
                    SizedBox(width: 8.w),
                    HadithActionButton(
                      icon: Icons.share_rounded,
                      label: 'مشاركة كبطاقة',
                      onTap: onShare,
                      isDark: isDark,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HadithActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isDark;

  const HadithActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDarkElevated : const Color(0xFFF5F3ED),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.borderLight,
              width: 0.7,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.r,
                color: iconColor ??
                    (isDark
                        ? AppColors.accentGoldLight
                        : AppColors.accentGold),
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textWhite
                      : AppColors.textDarkPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
