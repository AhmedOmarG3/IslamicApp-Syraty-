import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart'
    show QuranReciter;
import 'package:siraty/features/quran/presentation/cubit/mushaf_settings_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import 'package:siraty/features/quran/presentation/widgets/mushaf_theme_palette.dart';
import 'package:siraty/features/quran/presentation/widgets/tajweed_quick_sheet.dart';

/// Reading & audio settings bottom sheet (reciter, font size, paper theme,
/// fullscreen trigger). Reads/writes [MushafSettingsCubit] and
/// [QuranAudioCubit]; the host page only supplies the fullscreen toggle.
class ReadingSettingsSheet extends StatelessWidget {
  final VoidCallback onToggleFullScreen;

  const ReadingSettingsSheet({super.key, required this.onToggleFullScreen});

  static void show(
    BuildContext context, {
    required VoidCallback onToggleFullScreen,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => ReadingSettingsSheet(
        onToggleFullScreen: onToggleFullScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          color: AppColors.accentGold, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        'إعدادات المصحف والقراءة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // 1. Reciter Selection for Verse Audio
              Text(
                'القارئ المفضل لتلاوة الآيات',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14.sp,
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              BlocBuilder<QuranAudioCubit, QuranAudioState>(
                buildWhen: (prev, curr) =>
                    prev.selectedReciter != curr.selectedReciter,
                builder: (context, audioState) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardDarkElevated,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<QuranReciter>(
                        value: audioState.selectedReciter,
                        isExpanded: true,
                        dropdownColor: AppColors.cardDarkElevated,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.accentGold),
                        items: QuranAudioCubit.availableReciters.map((reciter) {
                          return DropdownMenuItem<QuranReciter>(
                            value: reciter,
                            child: Text(
                              '${reciter.name} (${reciter.subname})',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13.sp,
                                color: AppColors.textWhite,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (rec) {
                          if (rec != null) {
                            context.read<QuranAudioCubit>().setReciter(rec);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // 2. Font Size Slider & Controls
              BlocBuilder<MushafSettingsCubit, MushafSettingsState>(
                builder: (context, settings) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tajweed & Waqf Quick Guide Button
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          TajweedQuickSheet.show(context);
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.cardDarkElevated,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: AppColors.accentGold.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: AppColors.accentGold,
                                  size: 18.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'أحكام التجويد وعلامات الوقف',
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textWhite,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'دليل سريع لعلامات المصحف (مـ، لا، ج، صلى، قلى...) وأحكام التلاوة',
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 11.5.sp,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14.r,
                                color: AppColors.accentGold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 3. Mushaf Paper Theme Selection
                      Text(
                        'لون ورق المصحف',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14.sp,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          _buildThemeCard(
                            context: context,
                            title: 'ورق المدينة',
                            mode: MushafThemeMode.cream,
                            bgColor: const Color(0xFFFBF6EC),
                            textColor: const Color(0xFF141C18),
                            borderColor: const Color(0xFFBD9346),
                          ),
                          SizedBox(width: 8.w),
                          _buildThemeCard(
                            context: context,
                            title: 'الوضع الليلي',
                            mode: MushafThemeMode.night,
                            bgColor: const Color(0xFF131817),
                            textColor: const Color(0xFFF7F8F4),
                            borderColor: const Color(0xFFC7A567),
                          ),
                          SizedBox(width: 8.w),
                          _buildThemeCard(
                            context: context,
                            title: 'الوضع الدافئ',
                            mode: MushafThemeMode.sepia,
                            bgColor: const Color(0xFFF4EBD9),
                            textColor: const Color(0xFF281D10),
                            borderColor: const Color(0xFFA67C33),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 18.h),

              // 4. Fullscreen Mode Quick Trigger Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onToggleFullScreen();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardDarkElevated,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fullscreen_rounded,
                        color: AppColors.accentGold,
                        size: 22.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'تفعيل وضع الصفحة الكاملة (ملء الشاشة)',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required MushafThemeMode mode,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    final cubit = context.read<MushafSettingsCubit>();
    final isSelected = cubit.state.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => cubit.setThemeMode(mode),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentGold
                  : borderColor.withValues(alpha: 0.5),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                'بِسْمِ اللَّهِ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 11.sp,
                  color: textColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
