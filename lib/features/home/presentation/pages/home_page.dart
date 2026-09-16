import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/core/services/prayer_scheduler_interface.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/features/home/domain/services/daily_ayah_widget_service.dart';
import 'package:siraty/features/home/presentation/widgets/home_body.dart';
import 'package:siraty/features/prayer/data/services/location_service.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:siraty/features/prayer/domain/usecases/refresh_prayer_schedule_usecase.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_cubit.dart';
import 'package:siraty/features/prayer/presentation/widgets/autostart_guide_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptPermissions();
      DailyAyahWidgetService.updateWidget().catchError((_) {});
    });
  }

  Future<void> _checkAndPromptPermissions() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final locationService = getIt<LocationService>();
      final scheduler = getIt<PrayerSchedulerInterface>();

      final currentLocPerm = await locationService.checkPermission();
      final hasLocation = currentLocPerm == LocationPermission.always ||
          currentLocPerm == LocationPermission.whileInUse;

      final hasNotification = await scheduler.hasNotificationPermission();

      // Synchronize notification preference with actual OS permission:
      final prayerRepo = getIt<PrayerRepository>();
      final prefNotifications = await prayerRepo.getNotificationsEnabled();
      if (prefNotifications && !hasNotification) {
        // OS revoked permission or restored SharedPreferences from previous install
        await prayerRepo.setNotificationsEnabled(false);
      } else if (prefNotifications && hasNotification) {
        await getIt<RefreshPrayerScheduleUseCase>().call();
      }

      // If BOTH location and notification are already granted, no need to show dialog
      if (hasLocation && hasNotification) {
        return;
      }

      // If user has already been prompted previously and at least one is granted, don't nag
      final alreadyPrompted =
          prefs.getBool('initial_permission_dialog_shown') ?? false;
      if (alreadyPrompted && (hasLocation || hasNotification)) {
        return;
      }

      if (!mounted) return;

      // Show explanatory dialog with "تفعيل الآن" or "لاحقاً من الإعدادات"
      await _showPermissionExplainerDialog(
        needsLocation: !hasLocation,
        needsNotification: !hasNotification,
      );
    } catch (e) {
      debugPrint('Error in _checkAndPromptPermissions: $e');
    }
  }

  Future<void> _showPermissionExplainerDialog({
    required bool needsLocation,
    required bool needsNotification,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
            side: BorderSide(
              color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentGold, width: 1.2),
                  ),
                  child: Icon(
                    needsLocation
                        ? Icons.location_on_outlined
                        : Icons.notifications_active_outlined,
                    color: AppColors.accentGold,
                    size: 28.r,
                  ),
                ),
                SizedBox(height: 14.h),

                // Title
                Text(
                  needsLocation
                      ? 'مواقيت الصلاة والأذان في سيرتي'
                      : 'تنبيهات الأذان في سيرتي',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textDarkPrimary,
                  ),
                ),
                SizedBox(height: 10.h),

                // Explanation text
                Text(
                  needsLocation
                      ? 'لتحديد مدينتك وحساب أوقات الصلاة واتجاه القبلة بدقة متناهية، وتنبيهك بمواعيد الأذان، يرجى تفعيل إذن الموقع والإشعارات.'
                      : 'لتنبيهك بصوت الأذان والتذكير بمواقيت الصلاة في موعدها المضبوط في سيرتي، يرجى تفعيل إذن الإشعارات.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.sp,
                    height: 1.6,
                    color:
                        isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  ),
                ),
                SizedBox(height: 16.h),

                // Feature items
                if (needsLocation) ...[
                  _buildExplainerItem(
                    icon: Icons.access_time_rounded,
                    text: 'حساب مواقيت الصلوات بدقة لموقعك الحالي',
                    isDark: isDark,
                  ),
                  SizedBox(height: 8.h),
                  _buildExplainerItem(
                    icon: Icons.explore_outlined,
                    text: 'تحديد اتجاه القبلة الشريفة بدقة',
                    isDark: isDark,
                  ),
                  SizedBox(height: 8.h),
                ],
                if (needsNotification) ...[
                  _buildExplainerItem(
                    icon: Icons.notifications_active_outlined,
                    text: 'تنبيهات وأذان الصلوات في موعدها المضبوط',
                    isDark: isDark,
                  ),
                  SizedBox(height: 8.h),
                  _buildExplainerItem(
                    icon: Icons.bolt_rounded,
                    text: 'بدء التشغيل التلقائي (Autostart) لضمان عمل الأذان والشاشة مقفلة',
                    isDark: isDark,
                  ),
                ],
                SizedBox(height: 20.h),

                // Action Buttons
                // 1. Primary "تفعيل الآن"
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        side: const BorderSide(
                            color: AppColors.accentGold, width: 1),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = getIt<SharedPreferences>();
                      await prefs.setBool(
                          'initial_permission_dialog_shown', true);
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      await _executePermissionRequests(
                        needsLocation: needsLocation,
                        needsNotification: needsNotification,
                      );
                    },
                    child: Text(
                      'تفعيل الآن',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // 2. Secondary "لاحقاً من الإعدادات"
                TextButton(
                  onPressed: () async {
                    final prefs = getIt<SharedPreferences>();
                    await prefs.setBool(
                        'initial_permission_dialog_shown', true);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(
                    'لاحقاً من الإعدادات',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textDimmed
                          : AppColors.textDarkMuted,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExplainerItem({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.accentGold),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _executePermissionRequests({
    required bool needsLocation,
    required bool needsNotification,
  }) async {
    try {
      if (needsLocation) {
        final locationService = getIt<LocationService>();
        final locPerm = await locationService.requestPermission();
        if (locPerm == LocationPermission.always ||
            locPerm == LocationPermission.whileInUse) {
          if (mounted) {
            context.read<AzanCubit>().loadPrayerTimes();
          }
        }
      }

      if (needsNotification) {
        final scheduler = getIt<PrayerSchedulerInterface>();
        final granted = await scheduler.requestNotificationPermission();
        await scheduler.requestExactAlarmPermission();
        await scheduler.requestIgnoreBatteryOptimizations();

        final prayerRepo = getIt<PrayerRepository>();
        await prayerRepo.setNotificationsEnabled(granted);

        final isSupported = await scheduler.isAutoStartSupported();
        if (isSupported && granted) {
          final manufacturer = await scheduler.getDeviceManufacturer();
          if (mounted) {
            await AutostartGuideDialog.show(
              context,
              manufacturer: manufacturer,
              scheduler: scheduler,
            );
          }
        }
      }

      final prayerRepo = getIt<PrayerRepository>();
      final notifEnabled = await prayerRepo.getNotificationsEnabled();
      if (notifEnabled) {
        await getIt<RefreshPrayerScheduleUseCase>().call();
      }
    } catch (e) {
      debugPrint('Error executing permission requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        bottom: false,
        child: HomeBody(),
      ),
    );
  }
}
