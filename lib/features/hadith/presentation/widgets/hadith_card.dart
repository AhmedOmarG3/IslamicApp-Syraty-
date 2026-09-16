import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/islamic_ornament_painter.dart';
import 'package:siraty/features/hadith/data/models/hadith_model.dart';
import 'package:siraty/core/services/favorites_service.dart';

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
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: IslamicOrnamentPainter(
          primaryGold: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.45),
          borderWidth: 1.0,
          cornerSize: 14.r,
          showCornerFlourishes: true,
          showInnerBorder: true,
          showArch: false,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Number Pill + Book / Chapter Badge
              Row(
                children: [
                  // Hadith Badge Cartouche
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.accentGold, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_rounded, size: 12.r, color: AppColors.accentGold),
                        SizedBox(width: 4.w),
                        Text(
                          'حديث شريف',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Chapter / Category Badge
                  Expanded(
                    child: Text(
                      hadith.chapter.isNotEmpty ? hadith.chapter : hadith.book,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.accentGoldLight : AppColors.primaryGreen,
                      ),
                    ),
                  ),

                  // Source Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : const Color(0xFFF2F5F2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      hadith.book,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                      ),
                    ),
                  ),
                ],
              ),

              // Narrator if present
              if (hadith.narrator.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'عن ${hadith.narrator}:',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12.sp,
                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              SizedBox(height: 10.h),

              // Arabic Matn (Hadith Text)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.bgDark.withValues(alpha: 0.55)
                      : const Color(0xFFF9FBF8),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: SelectableText(
                  hadith.arabic,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16.5.sp,
                    height: 1.85,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  ),
                ),
              ),

              // Explanation / Benefit if available
              if (hadith.explanation.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '💡 ${hadith.explanation}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      height: 1.5,
                      color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 10.h),

              // Rosette Divider
              IslamicRosetteDivider(
                goldColor: AppColors.accentGold.withValues(alpha: isDark ? 0.3 : 0.4),
                height: 12.h,
              ),

              SizedBox(height: 8.h),

              // Action Buttons: Favorite, Copy, Share Card
              ListenableBuilder(
                listenable: FavoritesService.instance,
                builder: (context, _) {
                  final isFav = FavoritesService.instance.items.any(
                    (e) => (e.id == favId || e.id == hadith.id.toString()) && e.type == FavoriteType.hadith,
                  );
                  return Row(
                    children: [
                      HadithActionButton(
                        icon: isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        label: isFav ? 'محفوظ' : 'حفظ',
                        iconColor: isFav ? Colors.redAccent : AppColors.accentGold,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDarkElevated : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: iconColor ?? AppColors.accentGold),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
