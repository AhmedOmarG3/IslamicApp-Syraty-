import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

class HadithSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final bool isDark;
  final bool hasQuery;
  final double? height;
  final bool withShadow;

  const HadithSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    required this.onClear,
    required this.isDark,
    required this.hasQuery,
    this.height,
    this.withShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Container(
        height: height ?? 46.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          ),
          boxShadow: withShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13.5.sp,
            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintTextDirection: TextDirection.rtl,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.accentGold,
              size: 20.r,
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 18.r,
                      color: AppColors.textDimmed,
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: (height != null ? 9.h : 10.h),
              horizontal: 10.w,
            ),
          ),
        ),
      ),
    );
  }
}
