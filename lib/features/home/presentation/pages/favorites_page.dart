import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(title: 'المفضلة وملاحظاتي'),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ornate Geometric Bookmark Icon
              Container(
                width: 90.r,
                height: 90.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bookmark_outline_rounded,
                  size: 40.r,
                  color: AppColors.accentGold,
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'لا توجد آيات محفوظة بعد',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'أثناء القراءة، اضغط على أي آية ثم «حفظ» لتضيفها هنا، واكتب خاطرة أو تدبّرًا تعود إليه.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                  fontSize: 13.sp,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
