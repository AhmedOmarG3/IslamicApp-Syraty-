import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/ornament_divider.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  static const List<_PrayerRowData> _prayers = [
    _PrayerRowData(name: 'الفجر', time: '٤:٣٤', icon: Icons.wb_twilight_rounded, isNext: true),
    _PrayerRowData(name: 'الظهر', time: '١:٠١', icon: Icons.wb_sunny_outlined, isNext: false),
    _PrayerRowData(name: 'العصر', time: '٤:٣٩', icon: Icons.wb_sunny_rounded, isNext: false),
    _PrayerRowData(name: 'المغرب', time: '٧:٤٩', icon: Icons.nights_stay_outlined, isNext: false),
    _PrayerRowData(name: 'العشاء', time: '٩:١٦', icon: Icons.nights_stay_rounded, isNext: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: 'مواقيت الصلاة',
        showBackButton: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // City / Location Selection Bar
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.accentGold,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'موقعك',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'تغيير يدويًا',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.sageGreen : const Color(0xFF4A7D6E),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Auto location hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: isDark ? AppColors.textDimmed : const Color(0xFF7F8E87),
                  size: 13.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  'اضغط لتحديد موقعك تلقائيًا',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textDimmed : const Color(0xFF7F8E87),
                    fontSize: 11.5.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Ramadan Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withValues(alpha: 0.5)
                    : const Color(0xFFFAF6EF),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.accentGold.withValues(alpha: 0.5)
                      : const Color(0xFFD6BE97),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'معاينة وضع رمضان (يظهر تلقائيًا في الشهر الكريم)',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.accentGold : const Color(0xFFA27C44),
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Prayer Cards List
            Column(
              children: _prayers.map((p) {
                final cardBg = p.isNext
                    ? (isDark ? AppColors.cardDarkElevated : const Color(0xFFF7F2E7))
                    : (isDark ? AppColors.cardDark : AppColors.cardLight);

                final cardBorder = p.isNext
                    ? (isDark ? AppColors.borderGold : const Color(0xFFD6BE97))
                    : (isDark ? AppColors.borderSubtle : AppColors.borderLight);

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: cardBorder,
                      width: p.isNext ? 1.3 : 1,
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
                    children: [
                      // Icon in Circle
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardHighlight : const Color(0xFFEFE7D8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          p.icon,
                          color: p.isNext
                              ? (isDark ? AppColors.accentGold : const Color(0xFFA27C44))
                              : (isDark ? AppColors.sageGreen : const Color(0xFF6F887C)),
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 14.w),

                      // Prayer Name
                      Text(
                        p.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // "التالية" badge if active
                      if (p.isNext) ...[
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.accentGold.withValues(alpha: 0.25)
                                : const Color(0xFFA27C44),
                            borderRadius: BorderRadius.circular(12.r),
                            border: isDark
                                ? Border.all(color: AppColors.accentGold, width: 0.8)
                                : null,
                          ),
                          child: Text(
                            'التالية',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.accentGold : Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Prayer Time
                      Text(
                        p.time,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 12.h),

            OrnamentDivider(
              starColor: AppColors.accentGold,
              lineColor: isDark ? AppColors.borderSubtle : const Color(0xFFE5DEC9),
            ),
            SizedBox(height: 12.h),

            // Two Sub-feature Action Cards (Qibla & Hijri)
            Row(
              children: [
                // Qibla Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/qibla'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(18.r),
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
                      child: Column(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardHighlight : const Color(0xFFEFE7D8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.explore_outlined,
                              color: isDark ? AppColors.sageGreen : const Color(0xFF2E6351),
                              size: 22.r,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'اتجاه القبلة',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'بوصلة حيّة بالحسّاس',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textDimmed : const Color(0xFF7F8E87),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Hijri Calendar Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/hijri'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(18.r),
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
                      child: Column(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardHighlight : const Color(0xFFEFE7D8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.nights_stay_outlined,
                              color: isDark ? AppColors.sageGreen : const Color(0xFF2E6351),
                              size: 22.r,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'التقويم الهجري',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'رمضان ١٤٤٧',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textDimmed : const Color(0xFF7F8E87),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _PrayerRowData {
  final String name;
  final String time;
  final IconData icon;
  final bool isNext;

  const _PrayerRowData({
    required this.name,
    required this.time,
    required this.icon,
    required this.isNext,
  });
}
