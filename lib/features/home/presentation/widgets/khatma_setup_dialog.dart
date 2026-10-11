import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/app_snack_bar.dart';
import 'package:siraty/core/widgets/islamic_star_icon.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/domain/entities/khatma_model.dart';
import 'package:siraty/features/quran/domain/services/khatma_service.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/services/mushaf_page_service.dart';

class KhatmaSetupDialog extends StatefulWidget {
  final KhatmaModel? existingKhatma;
  const KhatmaSetupDialog({super.key, this.existingKhatma});

  static Future<void> show(BuildContext context, {KhatmaModel? existingKhatma}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KhatmaSetupDialog(existingKhatma: existingKhatma),
    );
  }

  @override
  State<KhatmaSetupDialog> createState() => _KhatmaSetupDialogState();
}

class _KhatmaSetupDialogState extends State<KhatmaSetupDialog> {
  // 0 = By Total Days (المدة بالأيام), 1 = By Pages Per Day (الورد بالصفحات)
  int _primaryMode = 0;

  // Days mode state
  int _selectedDays = 30;

  // Pages mode state
  int _selectedPagesPerDay = 20;

  // Start from bookmark
  bool _startFromLastRead = false;
  int _lastReadPage = 1;

  // Daily Reminder state
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 30); // 8:30 PM default

  bool get _isEditing => widget.existingKhatma != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingKhatma;
    if (existing != null) {
      _reminderEnabled = existing.reminderEnabled;
      _reminderTime = TimeOfDay(hour: existing.reminderHour, minute: existing.reminderMinute);
      if (existing.customDailyPages != null && existing.customDailyPages! > 0) {
        _primaryMode = 1;
        _selectedPagesPerDay = existing.customDailyPages!;
      } else {
        _primaryMode = 0;
        final remDays = existing.remainingDays;
        _selectedDays = remDays > 0 ? remDays : (existing.targetDays > 0 ? existing.targetDays : 30);
      }
    } else {
      final lastRead = LastReadService.lastReadNotifier.value;
      if (lastRead != null) {
        _lastReadPage = MushafPageService.getPageNumber(
          lastRead.surahNumber,
          lastRead.ayahNumber,
        );
      }
    }
  }

  int get _startPage => _startFromLastRead ? _lastReadPage : 1;
  int get _totalPages => (604 - _startPage + 1).clamp(1, 604);

  /// Pages remaining to be scheduled
  int get _effectivePagesToSchedule {
    if (_isEditing) {
      return (604 - widget.existingKhatma!.currentPage).clamp(1, 604);
    }
    return _totalPages;
  }

  /// Calculate daily pages when in Days mode (integer only)
  int get _calculatedPagesPerDay {
    final days = _selectedDays.clamp(1, 604);
    return (_effectivePagesToSchedule / days).ceil().clamp(1, 604);
  }

  /// Calculate total days when in Pages mode (integer only)
  int get _calculatedTotalDays {
    final pages = _selectedPagesPerDay.clamp(1, _effectivePagesToSchedule);
    return (_effectivePagesToSchedule / pages).ceil().clamp(1, 604);
  }

  int get _finalDays {
    return _primaryMode == 0 ? _selectedDays : _calculatedTotalDays;
  }

  String get _finalTitle {
    if (_primaryMode == 0) {
      if (_selectedDays == 30) return 'ختمة شهر (٣٠ يوماً)';
      if (_selectedDays == 60) return 'ختمة شهرين (٦٠ يوماً)';
      if (_selectedDays == 15) return 'ختمة سريعة (١٥ يوماً)';
      if (_selectedDays == 90) return 'ختمة ٣ أشهر (٩٠ يوماً)';
      return 'ختمة الـ $_selectedDays يوماً';
    } else {
      if (_selectedPagesPerDay == 20) return 'ختمة جزء يومياً (٣٠ يوماً)';
      if (_selectedPagesPerDay == 10) return 'ختمة نصف جزء (٦٠ يوماً)';
      return 'ختمة $_selectedPagesPerDay صفحات يومياً';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour12 = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour >= 12 ? 'مساءً (م)' : 'صباحاً (ص)';
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final splitHour = QuranMetadata.toArabicDigits(hour12);
    final splitMinute = minuteStr.split('').map((c) => QuranMetadata.toArabicDigits(int.parse(c))).join('');
    return '$splitHour:$splitMinute $period';
  }

  Future<void> _pickReminderTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      helpText: 'اختر وقت التذكير بالوِرد',
      hourLabelText: 'الساعة',
      minuteLabelText: 'الدقيقة',
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('ar'),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  dayPeriodBorderSide: const BorderSide(color: AppColors.accentGold, width: 1.2),
                  dayPeriodColor: WidgetStateColor.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.accentGold;
                    }
                    return isDark ? const Color(0xFF1B2F25) : const Color(0xFFF0F4F1);
                  }),
                  dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return isDark ? Colors.white70 : AppColors.textDarkPrimary;
                  }),
                  dayPeriodTextStyle: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  hourMinuteTextStyle: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  helpTextStyle: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: AppColors.accentGold,
                        onPrimary: Colors.white,
                        surface: Color(0xFF0F261D),
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: AppColors.accentGold,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textDarkPrimary,
                      ),
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B15) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Padding(
              padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
              child: Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ornate Header Card with 3D Luxury Holy Quran Image
                    _buildHeaderBanner(isDark),
                    SizedBox(height: 16.h),

                    // If editing: Show preserved progress badge
                    if (_isEditing) ...[
                      _buildPreservedProgressCard(isDark),
                    ],

                    // Primary Selection: [تحديد بعدد الأيام] vs [تحديد بعدد الصفحات]
                    _buildPrimaryModeSelector(isDark),
                    SizedBox(height: 16.h),

                    // Content for Selected Mode
                    if (_primaryMode == 0)
                      _buildDaysModeSection(isDark)
                    else
                      _buildPagesModeSection(isDark),
                    SizedBox(height: 16.h),

                    // Crystal-Clear Interactive Daily Reminder Section
                    _buildReminderSection(isDark),
                    SizedBox(height: 14.h),

                    // Start from Bookmark Toggle (if exists and creating new)
                    if (!_isEditing && _lastReadPage > 1 && _lastReadPage < 604) ...[
                      _buildBookmarkOption(isDark),
                      SizedBox(height: 16.h),
                    ],

                    // Grand Gold Start / Save Khatma Button
                    _buildStartButton(),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Luxury Header Banner with 3D Holy Quran Asset
  Widget _buildHeaderBanner(bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF062319),
            Color(0xFF0F3A2C),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062319).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 3D Luxury Holy Quran Image Emblem
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                AppAssets.khatmaIconLuxury,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  child: Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 28.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Header Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isEditing ? 'تعديل خطة الختمة' : 'خطة ختم القرآن الكريم',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _isEditing ? 'تعديل الخطة' : 'مُباركة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGoldLight,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  _isEditing
                      ? 'عدّل وتيرة وردك بالأيام أو الصفحات مع الحفاظ على إنجازك'
                      : 'حدد خطتك بالأيام أو بالصفحات مع تذكير يومي في موعدك',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.5.sp,
                    color: AppColors.accentGoldLight.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Close Button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Primary Mode Selector: [تحديد بعدد الأيام] vs [تحديد بعدد الصفحات]
  Widget _buildPrimaryModeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
          child: Row(
            children: [
              IslamicStarBadge(
                size: 20.r,
                color: AppColors.accentGold,
                child: Icon(Icons.tune_rounded, size: 9.r, color: AppColors.accentGold),
              ),
              SizedBox(width: 6.w),
              Text(
                'كيف تفضل تحديد ختمتك؟',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDarkPrimary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Mode 1: By Days
            Expanded(
              child: _buildModeCard(
                index: 0,
                title: 'تحديد بعدد الأيام',
                subtitle: 'مدة الختمة الكلية',
                icon: Icons.calendar_month_rounded,
                isSelected: _primaryMode == 0,
                isDark: isDark,
              ),
            ),
            SizedBox(width: 10.w),
            // Mode 2: By Pages
            Expanded(
              child: _buildModeCard(
                index: 1,
                title: 'تحديد بعدد الصفحات',
                subtitle: 'الوِرد اليومي المستهدف',
                icon: Icons.auto_stories_rounded,
                isSelected: _primaryMode == 1,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _primaryMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0F3A2C),
                    Color(0xFF072118),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF13251E) : const Color(0xFFF7F8F7)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGold.withValues(alpha: 0.22)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18.r,
                    color: isSelected ? AppColors.accentGold : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 18.r,
                  color: isSelected ? AppColors.accentGold : (isDark ? Colors.white30 : Colors.black26),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.textDarkPrimary),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 11.sp,
                  color: isSelected
                      ? AppColors.accentGoldLight
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Mode A: By Total Days Configuration
  Widget _buildDaysModeSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13251E) : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر مدة الختمة أو حدد أي عدد أيام:',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDarkPrimary,
            ),
          ),
          SizedBox(height: 10.h),

          // Preset 2x2 Grid (Balanced & Never Wraps Awkwardly)
          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  label: '٣٠ يوماً',
                  sub: 'شهر كامل · جزء يومياً',
                  isSelected: _selectedDays == 30,
                  onTap: () => setState(() => _selectedDays = 30),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildPresetCard(
                  label: '٦٠ يوماً',
                  sub: 'شهران · نصف جزء',
                  isSelected: _selectedDays == 60,
                  onTap: () => setState(() => _selectedDays = 60),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  label: '١٥ يوماً',
                  sub: 'سريعة · جزآن يومياً',
                  isSelected: _selectedDays == 15,
                  onTap: () => setState(() => _selectedDays = 15),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildPresetCard(
                  label: '٩٠ يوماً',
                  sub: '٣ أشهر · ربع جزء',
                  isSelected: _selectedDays == 90,
                  onTap: () => setState(() => _selectedDays = 90),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Stepper for Custom Days
          _buildNumericStepper(
            title: 'تخصيص عدد الأيام:',
            value: _selectedDays,
            unit: 'يوماً',
            isDark: isDark,
            onDecrement: () {
              if (_selectedDays > 3) {
                setState(() => _selectedDays--);
              }
            },
            onIncrement: () {
              if (_selectedDays < 604) {
                setState(() => _selectedDays++);
              }
            },
          ),
          SizedBox(height: 12.h),

          // Live Summary Banner
          _buildCalculationBanner(
            icon: Icons.auto_stories_rounded,
            title: 'وردك اليومي سيكون: ${QuranMetadata.toArabicDigits(_calculatedPagesPerDay)} صفحة كل يوم',
            subtitle: 'تختم خلال ${QuranMetadata.toArabicDigits(_selectedDays)} يوماً إن شاء الله',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// 4. Mode B: By Pages Per Day Configuration
  Widget _buildPagesModeSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13251E) : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر كمية الورد اليومي بالصفحات أو حدد رقماً مخصصاً:',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDarkPrimary,
            ),
          ),
          SizedBox(height: 10.h),

          // Preset 2x2 Grid (Balanced & Never Wraps Awkwardly)
          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  label: '٢٠ صفحة',
                  sub: 'جزء كامل (٣٠ يوماً)',
                  isSelected: _selectedPagesPerDay == 20,
                  onTap: () => setState(() => _selectedPagesPerDay = 20),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildPresetCard(
                  label: '١٠ صفحات',
                  sub: 'نصف جزء (٦٠ يوماً)',
                  isSelected: _selectedPagesPerDay == 10,
                  onTap: () => setState(() => _selectedPagesPerDay = 10),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  label: '٥ صفحات',
                  sub: 'ربع جزء (١٢١ يوماً)',
                  isSelected: _selectedPagesPerDay == 5,
                  onTap: () => setState(() => _selectedPagesPerDay = 5),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildPresetCard(
                  label: '٤٠ صفحة',
                  sub: 'جزآن (١٥ يوماً)',
                  isSelected: _selectedPagesPerDay == 40,
                  onTap: () => setState(() => _selectedPagesPerDay = 40),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Stepper for Custom Pages
          _buildNumericStepper(
            title: 'تخصيص عدد الصفحات يومياً:',
            value: _selectedPagesPerDay,
            unit: 'صفحات كل يوم',
            isDark: isDark,
            onDecrement: () {
              if (_selectedPagesPerDay > 1) {
                setState(() => _selectedPagesPerDay--);
              }
            },
            onIncrement: () {
              if (_selectedPagesPerDay < 100) {
                setState(() => _selectedPagesPerDay++);
              }
            },
          ),
          SizedBox(height: 12.h),

          // Live Summary Banner
          _buildCalculationBanner(
            icon: Icons.event_available_rounded,
            title: 'ستختم المصحف كاملاً في: ${QuranMetadata.toArabicDigits(_calculatedTotalDays)} يوماً',
            subtitle: 'بقراءة ${QuranMetadata.toArabicDigits(_selectedPagesPerDay)} صفحة يومياً إن شاء الله',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Preset Card Widget
  Widget _buildPresetCard({
    required String label,
    required String sub,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold.withValues(alpha: 0.18)
              : (isDark ? const Color(0xFF0E1C16) : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16.r,
              color: isSelected ? AppColors.accentGold : (isDark ? Colors.white38 : Colors.black26),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.accentGold
                          : (isDark ? Colors.white : AppColors.textDarkPrimary),
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 10.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tactile Numeric Stepper (Centered & Never Overflows)
  Widget _buildNumericStepper({
    required String title,
    required int value,
    required String unit,
    required bool isDark,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 13.sp,
            color: isDark ? Colors.white70 : AppColors.textDarkMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                isDark: isDark,
              ),
              Container(
                constraints: BoxConstraints(minWidth: 110.w),
                margin: EdgeInsets.symmetric(horizontal: 14.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0E1C16) : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${QuranMetadata.toArabicDigits(value)} $unit',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add_rounded,
                onTap: onIncrement,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 20.r, color: AppColors.accentGold),
      ),
    );
  }

  /// Live Calculation Banner
  Widget _buildCalculationBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGold.withValues(alpha: 0.16),
            AppColors.accentGold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.r, color: AppColors.accentGold),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Crystal-Clear Interactive Daily Reminder Section
  /// Addresses: "وبرضو تحديد موعد الورد هو كدا ممكن يفعل ميفهمش انه يقدر يحدد وقت هو"
  Widget _buildReminderSection(bool isDark) {
    // Quick time suggestions for convenience
    final quickTimes = [
      {'label': 'بعد الفجر (ص)', 'time': const TimeOfDay(hour: 5, minute: 30)},
      {'label': 'بعد الظهر (م)', 'time': const TimeOfDay(hour: 13, minute: 30)},
      {'label': 'بعد العشاء (م)', 'time': const TimeOfDay(hour: 20, minute: 30)},
      {'label': 'قبل النوم (م)', 'time': const TimeOfDay(hour: 22, minute: 0)},
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13251E) : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _reminderEnabled
              ? AppColors.accentGold.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
          width: _reminderEnabled ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Switch Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.accentGold,
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التذكير اليومي بموعد الورد',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDarkPrimary,
                        ),
                      ),
                      Text(
                        'تنبيه هادئ في الوقت المفضل لك يومياً',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 11.sp,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _reminderEnabled,
                activeTrackColor: AppColors.sageGreenContainer,
                activeThumbColor: AppColors.sageGreen,
                onChanged: (val) {
                  setState(() => _reminderEnabled = val);
                },
              ),
            ],
          ),

          // If enabled: Explicit Digital Time Display & Immediate Selector
          if (_reminderEnabled) ...[
            SizedBox(height: 12.h),

            // Prominent Gilded Clock Card - 100% Obvious that it is editable!
            InkWell(
              onTap: _pickReminderTime,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F3A2C),
                      Color(0xFF072118),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.accentGold,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IslamicStarBadge(
                          size: 38.r,
                          color: AppColors.accentGold,
                          child: Icon(
                            Icons.access_time_filled_rounded,
                            size: 16.r,
                            color: AppColors.accentGold,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'موعد التذكير المحدد:',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 11.sp,
                                color: AppColors.accentGoldLight,
                              ),
                            ),
                            Text(
                              _formatTimeOfDay(_reminderTime),
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Big Action Button: "اضغط لتعديل الوقت"
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_calendar_rounded, size: 14.r, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'تغيير الوقت',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Quick Islamic Time Shortcuts (أوقات مقترحة فورية)
            Row(
              children: [
                Text(
                  'أوقات مقترحة سريعة:',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: quickTimes.map((item) {
                        final t = item['time'] as TimeOfDay;
                        final isChosen = _reminderTime.hour == t.hour && _reminderTime.minute == t.minute;
                        return GestureDetector(
                          onTap: () => setState(() => _reminderTime = t),
                          child: Container(
                            margin: EdgeInsets.only(left: 6.w),
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? AppColors.accentGold.withValues(alpha: 0.25)
                                  : (isDark ? const Color(0xFF0E1C16) : Colors.white),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isChosen
                                    ? AppColors.accentGold
                                    : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                              ),
                            ),
                            child: Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 10.5.sp,
                                fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                                color: isChosen
                                    ? AppColors.accentGold
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 6. Start from Bookmark Option
  Widget _buildBookmarkOption(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13251E) : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark_added_rounded, color: AppColors.accentGold, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'البدء من آخر علامة قراءة (صـ ${QuranMetadata.toArabicDigits(_lastReadPage)})',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 12.5.sp,
                color: isDark ? Colors.white : AppColors.textDarkPrimary,
              ),
            ),
          ),
          Switch(
            value: _startFromLastRead,
            activeTrackColor: AppColors.sageGreenContainer,
            activeThumbColor: AppColors.sageGreen,
            onChanged: (val) => setState(() => _startFromLastRead = val),
          ),
        ],
      ),
    );
  }

  /// 7. Grand Gold Start Khatma Button
  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: () async {
          if (_isEditing) {
            final existing = widget.existingKhatma!;
            final elapsedDays = existing.currentDayNumber - 1;
            final remainingTargetDays = _primaryMode == 0 ? _selectedDays : _calculatedTotalDays;
            final newTotalDays = elapsedDays + remainingTargetDays;
            final customDaily = _primaryMode == 1 ? _selectedPagesPerDay : null;

            await KhatmaService.updateKhatmaPlan(
              newTargetDays: newTotalDays,
              customDailyPages: customDaily,
              customTitle: _finalTitle,
              reminderEnabled: _reminderEnabled,
              reminderHour: _reminderTime.hour,
              reminderMinute: _reminderTime.minute,
            );
            if (mounted) {
              Navigator.pop(context);
              AppSnackBar.showSuccess(
                context,
                message: 'تم تحديث خطة الختمة بنجاح مع الحفاظ على تقدمك المبارك 🌿',
              );
            }
          } else {
            await KhatmaService.startKhatma(
              targetDays: _finalDays,
              startPage: _startPage,
              customTitle: _finalTitle,
              reminderEnabled: _reminderEnabled,
              reminderHour: _reminderTime.hour,
              reminderMinute: _reminderTime.minute,
            );
            if (mounted) {
              Navigator.pop(context);
              AppSnackBar.showSuccess(
                context,
                message: 'تم بدء الختمة المباركة بنجاح، تقبل الله طاعتكم 🌿',
              );
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.accentGold,
                Color(0xFFE2B258),
                AppColors.accentGold,
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFF9E7BA),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IslamicStarBadge(
                size: 26.r,
                color: Colors.white,
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ),
              SizedBox(width: 8.w),
              Text(
                _isEditing
                    ? 'حفظ التعديلات ومواصلة الختمة'
                    : 'توكلت على الله · ابدأ الختمة المباركة',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Preserved Progress Banner shown when editing an active Khatma
  Widget _buildPreservedProgressCard(bool isDark) {
    final existing = widget.existingKhatma!;
    final readPages = existing.currentPage;
    final remaining = (604 - readPages).clamp(0, 604);
    final ratio = (readPages / 604 * 100).toStringAsFixed(0);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: const Color(0xFF143B2A).withValues(alpha: isDark ? 0.85 : 0.65),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF48B682).withValues(alpha: 0.7),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143B2A).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: const BoxDecoration(
              color: Color(0xFF48B682),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 18),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقدمك محفوظ ومستمر (وصلت إلى صـ ${QuranMetadata.toArabicDigits(readPages)} من ٦٠٤)',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'أنجزت ${QuranMetadata.toArabicDigits(int.parse(ratio))}% من المصحف · الصفحات المتبقية: ${QuranMetadata.toArabicDigits(remaining)} صفحة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.5.sp,
                    color: const Color(0xFF86E2A3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
