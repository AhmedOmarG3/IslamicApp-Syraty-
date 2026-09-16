import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_location.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:siraty/features/prayer/presentation/widgets/islamic_qibla_compass.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _heading;
  double _qiblaBearing = 136.0; // Default Cairo to Makkah approx
  String _cityName = 'القاهرة';
  bool _hasCompassSensor = true;
  bool _isAligned = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndCompass();
  }

  Future<void> _initLocationAndCompass() async {
    try {
      final prayerRepo = getIt<PrayerRepository>();
      final location = await prayerRepo.getSavedLocation();
      _applyLocation(location);
    } catch (_) {
      // Cairo default fallback
      _qiblaBearing = Qibla.qibla(const Coordinates(30.0444, 31.2357));
    }

    _startCompassStream();
  }

  void _applyLocation(PrayerLocation location) {
    setState(() {
      _cityName = location.cityName;
      _qiblaBearing = Qibla.qibla(Coordinates(location.latitude, location.longitude));
    });
  }

  void _startCompassStream() {
    if (FlutterCompass.events == null) {
      setState(() {
        _hasCompassSensor = false;
      });
      return;
    }

    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (!mounted) return;
      final heading = event.heading;
      if (heading == null) {
        setState(() {
          _hasCompassSensor = false;
        });
        return;
      }

      // Calculate alignment: difference between heading and Qibla bearing
      var diff = (_qiblaBearing - heading) % 360;
      if (diff < 0) diff += 360;
      final isAlignedNow = diff <= 4 || diff >= 356;

      if (isAlignedNow && !_isAligned) {
        HapticFeedback.mediumImpact();
      }

      setState(() {
        _heading = heading;
        _isAligned = isAlignedNow;
        _hasCompassSensor = true;
      });
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _hasCompassSensor = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate relative needle angle
    final currentHeading = _heading ?? 0.0;
    // When phone is at heading, needle should point towards qiblaBearing - currentHeading
    var relativeAngleDeg = (_qiblaBearing - currentHeading) % 360;
    if (relativeAngleDeg < 0) relativeAngleDeg += 360;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(title: 'اتجاه القبلة الشريفة'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // 1. Location Bar with Change Button
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
                      Icon(Icons.location_on_rounded, color: AppColors.accentGold, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        _cityName,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await context.push('/prayer-location');
                      // Reload updated location upon return
                      final prayerRepo = getIt<PrayerRepository>();
                      final location = await prayerRepo.getSavedLocation();
                      _applyLocation(location);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.accentGold, width: 0.8),
                      ),
                      child: Text(
                        'تغيير المدينة',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.accentGold : const Color(0xFF9E7B34),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 2. Compass Dial Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: _isAligned
                      ? (isDark ? AppColors.accentGold : const Color(0xFF1E6B52))
                      : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                  width: _isAligned ? 2.0 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isAligned
                        ? (isDark ? AppColors.accentGold.withValues(alpha: 0.25) : const Color(0xFF1E6B52).withValues(alpha: 0.2))
                        : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: _isAligned ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Islamic Astrolabe Qibla Compass
                  IslamicQiblaCompass(
                    heading: _heading ?? 0.0,
                    qiblaBearing: _qiblaBearing,
                    isAligned: _isAligned,
                    size: 260,
                  ),
                  SizedBox(height: 20.h),

                  // Alignment Status Banner (Vivid high-contrast styling for both light & dark modes)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                    decoration: BoxDecoration(
                      color: _isAligned
                          ? (isDark ? const Color(0xFF1B4E3B) : const Color(0xFF1E6B52))
                          : (isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _isAligned
                            ? (isDark ? AppColors.accentGold : const Color(0xFF0F4232))
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: _isAligned
                          ? [
                              BoxShadow(
                                color: (isDark ? AppColors.accentGold : const Color(0xFF1E6B52)).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                          size: 20.r,
                          color: _isAligned ? Colors.white : (isDark ? AppColors.sageGreen : const Color(0xFF265947)),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isAligned
                              ? 'أنت باتجاه القبلة الشريفة الآن ✓'
                              : 'وجّه الهاتف حتى يتطابق السهم للأعلى',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5.sp,
                            color: _isAligned
                                ? Colors.white
                                : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Angle & Direction Info
                  Text(
                    '${QuranMetadata.toArabicDigits(_qiblaBearing.round())}°',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.sageGreen : const Color(0xFF2E6351),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'زاوية القبلة عن الشمال لمدينة $_cityName',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                      fontSize: 13.sp,
                    ),
                  ),
                  if (_heading != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'اتجاه هاتفك الحالي: ${QuranMetadata.toArabicDigits(_heading!.round())}°',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Sensor note footnote
            if (!_hasCompassSensor)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.amber, width: 0.8),
                ),
                child: Text(
                  'تنبيه: جهازك لا يحتوي على حساس بوصلة مغناطيسي. استرشد بالزاوية ${QuranMetadata.toArabicDigits(_qiblaBearing.round())}° بالنسبة للشمال الجغرافي.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.amber.shade800,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
              )
            else
              Text(
                'تعتمد الدقّة على حسّاس البوصلة في جهازك — ابتعد عن المعادن والأجهزة المغناطيسية لتحصل على أدقّ اتجاه.',
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

