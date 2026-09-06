import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Color? titleColor;

  const AppHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.trailing,
    this.titleColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72.h : 60.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      bottom: false,
      child: Container(
        constraints: BoxConstraints(minHeight: preferredSize.height),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            // Back button or empty space for symmetry
            if (showBackButton)
              GestureDetector(
                onTap: () {
                  if (onBack != null) {
                    onBack!();
                  } else if (context.canPop()) {
                    context.pop();
                  }
                },
                child: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16.r,
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  ),
                ),
              )
            else
              SizedBox(width: 38.r),

            // Centered Title & Subtitle
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: titleColor ?? (isDark ? AppColors.sageGreen : AppColors.sageGreenDark),
                        fontSize: 18.sp,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Trailing widget or empty space for symmetry
            if (trailing != null)
              trailing!
            else
              SizedBox(width: 38.r),
          ],
        ),
      ),
    );
  }
}
