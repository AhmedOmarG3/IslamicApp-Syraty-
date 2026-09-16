import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

class HadithCollectionCard extends StatelessWidget {
  final Map<String, String> collection;
  final bool isDark;
  final VoidCallback onTap;

  const HadithCollectionCard({
    super.key,
    required this.collection,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGold = collection['tagColor'] == 'gold';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isGold
              ? AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.5)
              : AppColors.sageGreen.withValues(alpha: isDark ? 0.35 : 0.5),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: isGold
                        ? (isDark
                            ? AppColors.cardHighlight
                            : AppColors.iconBgCircleLight)
                        : (isDark
                            ? AppColors.sageGreen.withValues(alpha: 0.15)
                            : AppColors.iconBgCircleLight),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isGold
                          ? AppColors.accentGold.withValues(alpha: 0.5)
                          : AppColors.sageGreen.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: isGold
                        ? AppColors.accentGold
                        : AppColors.sageGreenDark,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 14.w),

                // Collection Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              collection['label']!,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDarkPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isGold
                                  ? AppColors.accentGold
                                      .withValues(alpha: 0.15)
                                  : AppColors.sageGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              collection['badge']!,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: isGold
                                    ? AppColors.accentGold
                                    : AppColors.sageGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        collection['author']!,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 11.5.sp,
                          color: isDark
                              ? AppColors.textDimmed
                              : AppColors.textDarkMuted,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        collection['description']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.45,
                          color: isDark
                              ? AppColors.textDimmed.withValues(alpha: 0.85)
                              : AppColors.textDarkMuted,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDarkElevated
                              : const Color(0xFFF2F5F2),
                        ),
                        child: Text(
                          collection['subtitle']!,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.accentGoldLight
                                : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(top: 14.h),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.r,
                    color: isDark
                        ? AppColors.textDimmed
                        : AppColors.textDarkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
