import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/di/service_locator.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/prayer_scheduler_interface.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/ornament_divider.dart';
import '../../../prayer/domain/entities/adhan_reciter.dart';
import '../../../prayer/domain/entities/calculation_method_setting.dart';
import '../../../prayer/domain/repositories/prayer_repository.dart';
import '../../../prayer/domain/usecases/refresh_prayer_schedule_usecase.dart';
import '../../../prayer/presentation/cubit/azan_cubit.dart';
import '../../../prayer/presentation/cubit/azan_state.dart';
import '../../../prayer/presentation/widgets/autostart_guide_dialog.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../quran/data/services/quran_download_service.dart';
import '../../../quran/data/services/quran_audio_service.dart';
import '../../../quran/presentation/cubit/quran_download_cubit.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/downloaded_audio_sheet.dart';
import '../widgets/haptic_settings_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PrayerRepository _prayerRepo = getIt<PrayerRepository>();
  final PrayerSchedulerInterface _scheduler = getIt<PrayerSchedulerInterface>();
  final RefreshPrayerScheduleUseCase _refreshSchedule = getIt<RefreshPrayerScheduleUseCase>();

  final HapticService _hapticService = getIt<HapticService>();
  bool _azanNotifications = true;
  bool _ongoingNotification = true;
  AdhanReciter _selectedReciter = AdhanReciter.defaultReciter;
  AdhanReciter _selectedFajrReciter = AdhanReciter.defaultReciter;
  CalculationMethodSetting _calculationSetting = const CalculationMethodSetting();

  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _playingSampleType; // null, 'regular', or 'fajr'

  @override
  void initState() {
    super.initState();
    _loadPrayerSettings();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerSettings() async {
    final prefNotifications = await _prayerRepo.getNotificationsEnabled();
    final hasSystemPermission = await _scheduler.hasNotificationPermission();
    // Notifications are only truly enabled if BOTH the user enabled them and Android granted permission
    final notifications = prefNotifications && hasSystemPermission;
    if (prefNotifications != notifications) {
      await _prayerRepo.setNotificationsEnabled(notifications);
    }

    final ongoing = await _prayerRepo.getOngoingNotificationEnabled();
    final reciter = await _prayerRepo.getSelectedReciter();
    final fajrReciter = await _prayerRepo.getSelectedFajrReciter();
    final method = await _prayerRepo.getCalculationMethodSetting();

    if (mounted) {
      setState(() {
        _azanNotifications = notifications;
        _ongoingNotification = ongoing;
        _selectedReciter = reciter;
        _selectedFajrReciter = fajrReciter;
        _calculationSetting = method;
      });
    }
  }

  Future<void> _toggleOngoingNotification(bool val) async {
    setState(() => _ongoingNotification = val);
    await _prayerRepo.setOngoingNotificationEnabled(val);
    await _scheduler.setOngoingNotificationEnabled(val);
    if (val) {
      await _scheduler.updateOngoingNotification();
    }
  }

  String _getHapticStrengthTitle(HapticStrength strength) {
    switch (strength) {
      case HapticStrength.off:
        return 'معطّل (بدون اهتزاز)';
      case HapticStrength.light:
        return 'خفيف (الافتراضي)';
      case HapticStrength.medium:
        return 'متوسط';
      case HapticStrength.heavy:
        return 'قوي';
    }
  }

  Future<void> _toggleNotifications(bool val) async {
    if (val) {
      final granted = await _scheduler.requestNotificationPermission();
      if (!granted) {
        // User denied system notification permission
        setState(() => _azanNotifications = false);
        await _prayerRepo.setNotificationsEnabled(false);
        return;
      }

      setState(() => _azanNotifications = true);
      await _prayerRepo.setNotificationsEnabled(true);

      await _scheduler.requestExactAlarmPermission();
      await _scheduler.requestIgnoreBatteryOptimizations();

      final isSupported = await _scheduler.isAutoStartSupported();
      if (isSupported) {
        final manufacturer = await _scheduler.getDeviceManufacturer();
        if (mounted) {
          await AutostartGuideDialog.show(
            context,
            manufacturer: manufacturer,
            scheduler: _scheduler,
          );
        }
      }
    } else {
      setState(() => _azanNotifications = false);
      await _prayerRepo.setNotificationsEnabled(false);
    }

    await _refreshSchedule();
  }

  Future<void> _toggleSamplePlayback({required bool isFajr}) async {
    final type = isFajr ? 'fajr' : 'regular';
    if (_playingSampleType == type) {
      await _audioPlayer?.stop();
      if (mounted) setState(() => _playingSampleType = null);
      return;
    }

    _audioPlayer ??= AudioPlayer();
    await _audioPlayer!.stop();

    // Pause Quran recitation if currently playing so they don't overlap
    try {
      final quranService = getIt<QuranAudioService>();
      if (quranService.isPlayingNotifier.value) {
        await quranService.pause();
      }
    } catch (_) {}

    try {
      if (mounted) setState(() => _playingSampleType = type);
      final reciter = isFajr ? _selectedFajrReciter : _selectedReciter;
      final previewUri = reciter.getPreviewUri(isFajr: isFajr);

      final mediaItem = MediaItem(
        id: previewUri,
        album: 'الأذان',
        title: isFajr ? 'أذان صلاة الفجر' : 'أذان باقي الصلوات',
        artist: reciter.displayName,
      );

      await _playerStateSubscription?.cancel();
      _playerStateSubscription = _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted && _playingSampleType == type) {
            setState(() => _playingSampleType = null);
          }
        }
      });

      // Plays the same res/raw file the native alarm service uses, so the
      // adhan is bundled only once.
      try {
        await _audioPlayer!.setAudioSource(
          AudioSource.uri(Uri.parse(previewUri), tag: mediaItem),
        );
      } catch (sourceErr) {
        debugPrint('Adhan preview primary URI failed: $sourceErr, trying fallback URI...');
        final altUri = previewUri.replaceFirst('/raw/', '/');
        await _audioPlayer!.setAudioSource(
          AudioSource.uri(Uri.parse(altUri), tag: mediaItem),
        );
      }
      await _audioPlayer!.play();
    } catch (e) {
      debugPrint('Adhan preview audio playback error: $e');
      if (mounted) {
        setState(() => _playingSampleType = null);
        AppSnackBar.showError(
          context,
          message: 'تعذّر تشغيل المعاينة، جرّب مرة أخرى',
        );
      }
    }
  }

  void _showReciterPicker({required bool isFajr}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSelected = isFajr ? _selectedFajrReciter : _selectedReciter;
    final recitersList = isFajr ? AdhanReciter.fajrReciters : AdhanReciter.regularReciters;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFajr ? 'اختر مؤذن صلاة الفجر' : 'اختر مؤذن باقي الصلوات',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                ),
              ),
              if (isFajr) ...[
                SizedBox(height: 4.h),
                Text(
                  'أذان الفجر مخصص ويتضمن جملة (الصلاة خيرٌ من النوم)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              ...recitersList.map((reciter) {
                final isSelected = reciter.id == currentSelected.id;
                return ListTile(
                  title: Text(
                    reciter.displayName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected
                          ? AppColors.accentGold
                          : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (isFajr) {
                      setState(() => _selectedFajrReciter = reciter);
                      await _prayerRepo.setSelectedFajrReciter(reciter.id);
                    } else {
                      setState(() => _selectedReciter = reciter);
                      await _prayerRepo.setSelectedReciter(reciter.id);
                    }
                    await _refreshSchedule();
                    // Stop playing sample if running
                    if (_playingSampleType != null) {
                      await _audioPlayer?.stop();
                      if (mounted) setState(() => _playingSampleType = null);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showMethodPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'طريقة حساب مواقيت الصلاة',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              ...CalculationMethod.values.map((method) {
                final isSelected = method == _calculationSetting.method;
                final setting = _calculationSetting.copyWith(method: method);
                return ListTile(
                  title: Text(
                    setting.methodArabicName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected
                          ? AppColors.accentGold
                          : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final updated = _calculationSetting.copyWith(method: method);
                    setState(() => _calculationSetting = updated);
                    if (mounted) {
                      await context.read<AzanCubit>().changeCalculationMethod(updated);
                      await _refreshSchedule();
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleDaylightSaving(bool val) async {
    final updated = _calculationSetting.copyWith(daylightSaving: val);
    setState(() => _calculationSetting = updated);
    await context.read<AzanCubit>().changeCalculationMethod(updated);
    await _refreshSchedule();
    if (mounted) {
      AppSnackBar.showSuccess(
        context,
        message: val
            ? 'تم تفعيل التوقيت الصيفي (+1 ساعة) وتحديث جميع المواقيت والمنبهات'
            : 'تم تعطيل التوقيت الصيفي واستعادة التوقيت القياسي',
      );
    }
  }

  void _shareApp() {
    const appUrl = 'https://play.google.com/store/apps/details?id=com.ahmed.siraty';
    const message = '''🌙 تطبيق سِيرتي | رفيقك اليومي للقرآن والأذكار ومواقيت الصلاة

قال رسول الله ﷺ: «مَن دلَّ على خيرٍ فله مثلُ أجرِ فاعلِه»

✨ أهم مميزات التطبيق:
📖 المصحف الشريف كاملاً: مطابق لطبعة مجمع الملك فهد بخط الرسم العثماني النقي مع التفسير الميسر، وحفظ علامة القراءة (يعمل بالكامل بدون إنترنت).
🎧 استماع صوتي نقي: تلاوة القرآن الكريم بأصوات كبار قراء العالم الإسلامي مع مشغل صوتي مدمج في شاشة القفل والإشعارات.
🕌 مواقيت الصلاة والأذان: حساب دقيق لمواقيت الصلوات الخمس مع تنبيهات الأذان بصوت مؤذني الحرمين المكي والمدني ومصر.
📿 الأذكار وحصن المسلم: أذكار الصباح والمساء، النوم، الاستيقاظ، وأدعية القرآن والسنة مع سبحة إلكترونية تفاعلية.
📚 السنة النبوية الشريفة: أحاديث صحيحي البخاري ومسلم وشروح ميسرة، مع ميزة بطاقات الآيات والأحاديث للمشاركة.
🧭 اتجاه القبلة الدقيق: بوصلة ذكية تحدد اتجاه الكعبة المشرفة بدقة متناهية من أي مكان حول العالم.
📱 ويدجت الشاشة الرئيسية: آية اليوم ومواقيت الصلاة المباشرة تزين شاشة هاتفك الرئيسية بذكر الله.
🚫 تطبيق إسلامي خالص: تجربة نقية تماماً وبدون أي إعلانات لوجه الله تعالى.

📲 حمّل التطبيق الآن وشاركه مع أحبابك ليكون لك صدقة جارية:
$appUrl''';

    Share.share(message);
  }

  Future<void> _rateApp() async {
    const channel = MethodChannel('siraty/app_channel');
    try {
      await channel.invokeMethod<bool>('openStoreListing');
    } catch (_) {}
  }

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
            // ---------------------------------------------------------------
            // 1. المظهر العام (Appearance)
            // ---------------------------------------------------------------
            _buildSectionHeader(
              isDark: isDark,
              title: 'المظهر العام',
              icon: Icons.palette_outlined,
            ),
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.nightlight_round,
              title: 'الوضع الليلي',
              subtitle: isDark
                  ? 'مفعّل — راحة للعين ليلاً'
                  : 'معطّل — الوضع النهاري مفعّل',
              trailing: Switch(
                value: isDark,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor: AppColors.borderLight,
                inactiveThumbColor: AppColors.sageGreenDark,
                onChanged: (val) => themeCubit.toggleTheme(),
              ),
            ),
            SizedBox(height: 16.h),

            const OrnamentDivider(),
            SizedBox(height: 10.h),

            // ---------------------------------------------------------------
            // 2. مواقيت الصلاة والأذان (Prayer Times & Adhan)
            // ---------------------------------------------------------------
            _buildSectionHeader(
              isDark: isDark,
              title: 'مواقيت الصلاة والأذان',
              icon: Icons.access_time_filled_rounded,
            ),

            // Azan Notifications Card
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.notifications_active_rounded,
              title: 'الأذان والتنبيهات',
              subtitle: _azanNotifications
                  ? 'يُرفع الأذان وتصلك تذكيرات قبل الصلاة بـ ١٠ دقائق'
                  : 'التنبيهات والأذان معطّلة حالياً',
              trailing: Switch(
                value: _azanNotifications,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor:
                    isDark ? AppColors.cardHighlight : AppColors.borderLight,
                inactiveThumbColor:
                    isDark ? AppColors.textMuted : AppColors.sageGreenDark,
                onChanged: _toggleNotifications,
              ),
            ),
            SizedBox(height: 10.h),

            // Ongoing Prayer Notification Card (الإشعار الدائم لمواقيت الصلاة)
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.push_pin_outlined,
              title: 'الإشعار الدائم لمواقيت الصلاة',
              subtitle: _ongoingNotification
                  ? 'مفعّل — يعرض الصلاة القادمة والمواقيت باستمرار في شريط التنبيهات'
                  : 'معطّل — إشعار مواقيت الصلاة الدائم متوقف',
              trailing: Switch(
                value: _ongoingNotification,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor:
                    isDark ? AppColors.cardHighlight : AppColors.borderLight,
                inactiveThumbColor:
                    isDark ? AppColors.textMuted : AppColors.sageGreenDark,
                onChanged: _toggleOngoingNotification,
              ),
            ),
            SizedBox(height: 10.h),

            // Daylight Saving Card (التوقيت الصيفي)
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.schedule_rounded,
              title: 'التوقيت الصيفي (+1 ساعة)',
              subtitle: _calculationSetting.daylightSaving
                  ? 'مفعّل — تم تقديم جميع مواقيت الصلاة ساعة واحدة'
                  : 'معطّل — التوقيت الشتوي القياسي مفعّل',
              trailing: Switch(
                value: _calculationSetting.daylightSaving,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor:
                    isDark ? AppColors.cardHighlight : AppColors.borderLight,
                inactiveThumbColor:
                    isDark ? AppColors.textMuted : AppColors.sageGreenDark,
                onChanged: _toggleDaylightSaving,
              ),
            ),
            SizedBox(height: 10.h),

            // Location Card
            BlocBuilder<AzanCubit, AzanState>(
              builder: (context, state) {
                String locationText = 'القاهرة (مصر)';
                if (state is AzanLoadedState) {
                  final loc = state.derivedToday.location;
                  locationText = '${loc.cityName} (${loc.countryName})';
                }

                return InkWell(
                  onTap: () => context.push('/prayer-location'),
                  borderRadius: BorderRadius.circular(18.r),
                  child: _buildSettingCard(
                    isDark: isDark,
                    icon: Icons.location_on_outlined,
                    title: 'الموقع والمواقيت',
                    subtitle: '$locationText · حساب فلكي محلي دقيق',
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardHighlight
                            : AppColors.iconBgCircleLight,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'تغيير',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textDarkPrimary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),

            // Calculation Method Card
            InkWell(
              onTap: _showMethodPicker,
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.tune_rounded,
                title: 'طريقة الحساب ومذهب العصر',
                subtitle: '${_calculationSetting.methodArabicName} · ${_calculationSetting.madhabArabicName}',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  size: 16.r,
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Autostart Card
            InkWell(
              onTap: () async {
                final manufacturer = await _scheduler.getDeviceManufacturer();
                if (context.mounted) {
                  await AutostartGuideDialog.show(
                    context,
                    manufacturer: manufacturer,
                    scheduler: _scheduler,
                  );
                }
              },
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.bolt_rounded,
                title: 'بدء التشغيل التلقائي (Autostart)',
                subtitle: 'لضمان دقة الأذان عند قفل الشاشة في الخلفية',
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderGold, width: 1),
                  ),
                  child: Text(
                    'تفعيل',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // 1. Fajr Adhan Selection Card (أذان صلاة الفجر)
            InkWell(
              onTap: () => _showReciterPicker(isFajr: true),
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.wb_twilight_rounded,
                title: 'صوت أذان صلاة الفجر',
                subtitle: '${_selectedFajrReciter.displayName} (الصلاة خير من النوم)',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  size: 16.r,
                ),
              ),
            ),
            SizedBox(height: 6.h),

            // Fajr Audio Sample Test Button
            InkWell(
              onTap: () => _toggleSamplePlayback(isFajr: true),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _playingSampleType == 'fajr' ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: AppColors.accentGold,
                      size: 18.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _playingSampleType == 'fajr' ? 'إيقاف الاستماع' : 'استماع لمقطع أذان الفجر',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // 2. Regular Prayers Adhan Selection Card (أذان باقي الصلوات)
            InkWell(
              onTap: () => _showReciterPicker(isFajr: false),
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.record_voice_over_rounded,
                title: 'صوت أذان باقي الصلوات',
                subtitle: '${_selectedReciter.displayName} (الظهر، العصر، المغرب، العشاء)',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  size: 16.r,
                ),
              ),
            ),
            SizedBox(height: 6.h),

            // Regular Prayers Audio Sample Test Button
            InkWell(
              onTap: () => _toggleSamplePlayback(isFajr: false),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _playingSampleType == 'regular' ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: AppColors.accentGold,
                      size: 18.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _playingSampleType == 'regular' ? 'إيقاف الاستماع' : 'استماع لمقطع أذان باقي الصلوات',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            const OrnamentDivider(),
            SizedBox(height: 10.h),

            // ---------------------------------------------------------------
            // 3. القرآن الكريم والتلاوات (Quran & Audio Storage)
            // ---------------------------------------------------------------
            _buildSectionHeader(
              isDark: isDark,
              title: 'القرآن الكريم والتلاوات',
              icon: Icons.menu_book_rounded,
            ),
            // Offline Audio Storage Management Card
            _buildStorageManagementCard(isDark),
            SizedBox(height: 16.h),

            const OrnamentDivider(),
            SizedBox(height: 10.h),

            // ---------------------------------------------------------------
            // 4. الأذكار والسبحة (الاهتزاز والتفاعل اللمسي)
            // ---------------------------------------------------------------
            _buildSectionHeader(
              isDark: isDark,
              title: 'الأذكار والسبحة (الاهتزاز والتفاعل)',
              icon: Icons.vibration_rounded,
            ),

            // Haptic Strength Selector Card
            InkWell(
              onTap: () => HapticSettingsSheet.show(
                context,
                hapticService: _hapticService,
                onUpdated: () => setState(() {}),
              ),
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.touch_app_rounded,
                title: 'قوة اهتزاز زر الأذكار والتسبيح',
                subtitle: _getHapticStrengthTitle(_hapticService.strength),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardHighlight
                        : AppColors.iconBgCircleLight,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'تعديل',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textDarkPrimary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Completion Vibration Toggle
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.done_all_rounded,
              title: 'اهتزاز إتمام الورد أو الدورة',
              subtitle: _hapticService.completionEnabled
                  ? 'مفعّل — نبضة مميزة عند إنهاء الذكر أو 33 تسبيحة'
                  : 'معطّل',
              trailing: Switch(
                value: _hapticService.completionEnabled,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                inactiveTrackColor:
                    isDark ? AppColors.cardHighlight : AppColors.borderLight,
                inactiveThumbColor:
                    isDark ? AppColors.textMuted : AppColors.sageGreenDark,
                onChanged: (val) async {
                  await _hapticService.setCompletionEnabled(val);
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: 16.h),

            const OrnamentDivider(),
            SizedBox(height: 10.h),

            // ---------------------------------------------------------------
            // 5. خدمات إسلامية (Islamic Services)
            // ---------------------------------------------------------------
            _buildSectionHeader(
              isDark: isDark,
              title: 'خدمات إسلامية',
              icon: Icons.volunteer_activism_outlined,
            ),
            // Zakat Card Link
            GestureDetector(
              onTap: () => context.push('/zakat'),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.monetization_on_outlined,
                title: 'حاسبة الزكاة',
                subtitle: 'طهّر مالك — بالجنيه المصري وفق أسعار الذهب والفضة',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  size: 16.r,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            const OrnamentDivider(),
            SizedBox(height: 10.h),

            // ---------------------------------------------------------------
            // 6. عن التطبيق والدعم (About & Community)
            // ---------------------------------------------------------------
            _buildSectionHeader(
              isDark: isDark,
              title: 'عن التطبيق',
              icon: Icons.info_outline_rounded,
            ),

            // Share App Card
            InkWell(
              onTap: _shareApp,
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.share_rounded,
                title: 'مشاركة التطبيق',
                subtitle: 'الدال على الخير كفاعله — انشر التطبيق ولك الأجر',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  size: 16.r,
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Rate App Card
            InkWell(
              onTap: _rateApp,
              borderRadius: BorderRadius.circular(18.r),
              child: _buildSettingCard(
                isDark: isDark,
                icon: Icons.star_rate_rounded,
                title: 'تقييم التطبيق',
                subtitle: 'ادعمنا برأيك وتقييمك على متجر Google Play',
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
                  fontSize: 11.5.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required bool isDark,
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 10.h, right: 2.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentGold.withValues(alpha: 0.15)
                  : AppColors.iconBgCircleLight,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? AppColors.accentGold.withValues(alpha: 0.3) : AppColors.borderGold.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Icon(
              icon,
              size: 16.r,
              color: isDark ? AppColors.accentGold : AppColors.accentGold,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
            ),
          ),
        ],
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
              color: isDark
                  ? AppColors.cardHighlight
                  : AppColors.iconBgCircleLight,
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
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textDarkPrimary,
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

  Widget _buildStorageManagementCard(bool isDark) {
    final downloadCubit = context.watch<QuranDownloadCubit>();

    return FutureBuilder<int>(
      future: downloadCubit.getTotalStorageBytes(),
      builder: (context, snapshot) {
        final totalBytes = snapshot.data ?? 0;
        final hasDownloads = totalBytes > 0;
        final formattedSize = QuranDownloadService.formatBytes(totalBytes);

        return InkWell(
          onTap: () => DownloadedAudioSheet.show(context),
          borderRadius: BorderRadius.circular(18.r),
          child: _buildSettingCard(
            isDark: isDark,
            icon: Icons.sd_storage_rounded,
            title: 'التلاوات المحملة دون إنترنت',
            subtitle: hasDownloads
                ? 'المساحة المستهلكة: $formattedSize · اضغط للتفاصيل والإدارة'
                : 'لا توجد سور محملة حالياً',
            trailing: hasDownloads
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.45)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'إدارة',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10.r,
                          color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                        ),
                      ],
                    ),
                  )
                : Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.emeraldGreen,
                    size: 20.r,
                  ),
          ),
        );
      },
    );
  }
}
