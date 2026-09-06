import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(title: 'اتجاه القبلة'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // Location Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: AppColors.accentGold, size: 18.r),
                      SizedBox(width: 8.w),
                      Text(
                        'القاهرة',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'تحديد موقعي',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.sageGreen : const Color(0xFF4A7D6E),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Compass Main Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Compass Dial
                  Container(
                    width: 200.r,
                    height: 200.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.borderGreen : const Color(0xFFD6BE97),
                        width: 1.5,
                      ),
                      color: isDark
                          ? AppColors.cardDarkElevated.withValues(alpha: 0.5)
                          : const Color(0xFFF7F2E7),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass Labels
                        Positioned(
                          top: 10.h,
                          child: Text(
                            'ش',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.h,
                          child: Text(
                            'ج',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12.w,
                          child: Text(
                            'ق',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12.w,
                          child: Text(
                            'غ',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Compass Needle (Golden & Sage)
                        Transform.rotate(
                          angle: -0.8, // points towards 292° approx
                          child: Container(
                            width: 130.w,
                            height: 28.h,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 12.h,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.sageGreen : const Color(0xFF2E6351),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.r),
                                        bottomLeft: Radius.circular(10.r),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 14.r,
                                  height: 14.r,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 12.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.r),
                                        bottomRight: Radius.circular(10.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Angle & Direction Text
                  Text(
                    '٢٩٢°',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.sageGreen : const Color(0xFF2E6351),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'عن الشمال نحو الكعبة المشرفة',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Activate Live Compass Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.sageGreen : const Color(0xFF1E4538),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                              .withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          color: isDark ? AppColors.bgDark : Colors.white,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'تفعيل البوصلة الحيّة',
                          style: AppTextStyles.buttonLabel.copyWith(
                            color: isDark ? AppColors.bgDark : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Sensor note footnote
            Text(
              'تعتمد الدقّة على حسّاس البوصلة في جهازك — ابتعد عن المعادن والأجهزة المغناطيسية للحصول على أدقّ اتجاه.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDimmed,
                fontSize: 11.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
