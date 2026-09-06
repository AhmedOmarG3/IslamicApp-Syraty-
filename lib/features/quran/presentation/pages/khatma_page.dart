import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/ornament_divider.dart';

class KhatmaPage extends StatefulWidget {
  const KhatmaPage({super.key});

  @override
  State<KhatmaPage> createState() => _KhatmaPageState();
}

class _KhatmaPageState extends State<KhatmaPage> {
  String _selectedDuration = 'شهر';

  final List<Map<String, String>> _durations = [
    {'title': 'شهر', 'sub': '٣٠ يومًا · جزء واحد يوميًا'},
    {'title': 'شهران', 'sub': '٦٠ يومًا · نصف جزء يوميًا'},
    {'title': 'نصف شهر', 'sub': '١٥ يومًا · جزءان يوميًا'},
    {'title': 'ثلاثة أشهر', 'sub': '٩٠ يومًا · ثُلث جزء يوميًا'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(title: 'خطة الختمة'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular Progress Indicator
                  Container(
                    width: 70.r,
                    height: 70.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentGold, width: 4.r),
                    ),
                    child: Text(
                      '30%',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ),
                  SizedBox(width: 18.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أتممتَ حتى الآن',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              '9',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'من ٣٠ جزءاً',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 15.sp,
                                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'تبقّى ٢١ جزءًا · على وِردك الحالي تُتمّ خلال ٢١ يومًا',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            OrnamentDivider(
              starColor: AppColors.accentGold,
              lineColor: isDark ? AppColors.borderSubtle : const Color(0xFFE5DEC9),
            ),
            SizedBox(height: 12.h),

            // Plan Duration Section
            Text(
              'اختر مدّة الختمة',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 12.h),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 2.2,
              ),
              itemCount: _durations.length,
              itemBuilder: (context, index) {
                final d = _durations[index];
                final isSelected = d['title'] == _selectedDuration;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d['title']!),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                            : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d['title']!,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          d['sub']!,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : (isDark ? AppColors.textMuted : AppColors.textDarkMuted),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),

            // Daily Target Action Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.borderGold, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وردك اليومي',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '21',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'صفحة يوميًا',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 15.sp,
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () => context.go('/quran'),
                    child: Container(
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
                      alignment: Alignment.center,
                      child: Text(
                        'ابدأ وِرد اليوم',
                        style: AppTextStyles.buttonLabel.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
