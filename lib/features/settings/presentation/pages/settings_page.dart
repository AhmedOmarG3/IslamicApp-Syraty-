import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/theme/theme_cubit.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/ornament_divider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _azanNotifications = true;

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(
        title: 'الإعدادات',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Setting Card
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.nightlight_round,
              title: 'الوضع الليلي',
              subtitle: isDark ? 'مفعّل — راحة للعين ليلاً' : 'معطّل — الوضع النهاري مفعّل',
              trailing: Switch(
                value: isDark,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor: AppColors.borderLight,
                inactiveThumbColor: AppColors.sageGreenDark,
                onChanged: (val) => themeCubit.toggleTheme(),
              ),
            ),
            SizedBox(height: 12.h),

            // Azan Notifications Card
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.notifications_active_rounded,
              title: 'الأذان والتنبيهات',
              subtitle: 'يُرفع الأذان ويصلك تنبيه عند كل صلاة',
              trailing: Switch(
                value: _azanNotifications,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor: isDark ? AppColors.cardHighlight : AppColors.borderLight,
                inactiveThumbColor: isDark ? AppColors.textMuted : AppColors.sageGreenDark,
                onChanged: (val) => setState(() => _azanNotifications = val),
              ),
            ),
            SizedBox(height: 12.h),

            // Azan Audio Test Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.borderGold, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: AppColors.accentGold, size: 20.r),
                  SizedBox(width: 6.w),
                  Text(
                    'استماع لمقطع الأذان',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Location Card
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.location_on_outlined,
              title: 'الموقع والمواقيت',
              subtitle: 'القاهرة · مواقيت افتراضية',
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'تحديث',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const OrnamentDivider(),
            SizedBox(height: 12.h),

            // Zakat Card Link
            GestureDetector(
              onTap: () => context.push('/zakat'),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.monetization_on_outlined,
                title: 'حاسبة الزكاة',
                subtitle: 'طهّر مالك — بالجنيه المصري',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  size: 16.r,
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // Footer
            Center(
              child: Text(
                'سِيرتي · صُنع بمحبّة لعبادةٍ هادئة',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
