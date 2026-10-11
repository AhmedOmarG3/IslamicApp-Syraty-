import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_snack_bar.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';
import 'package:siraty/core/widgets/islamic_star_icon.dart';
import 'package:siraty/features/home/presentation/widgets/khatma_setup_dialog.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/entities/khatma_model.dart';
import 'package:siraty/features/quran/domain/services/khatma_service.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';

class HomeKhatmaCard extends StatelessWidget {
  const HomeKhatmaCard({super.key});

  Future<void> _openPage(BuildContext context, int pageNumber) async {
    try {
      final pageData = quran.getPageData(pageNumber);
      final surahNum = pageData[0]['surah'] as int;
      final surah = await LastReadService.loadSurah(surahNum);
      if (surah != null && context.mounted) {
        context.push(
          '/surah-details',
          extra: {
            'surah': surah,
            'surahName': surah.surahName,
            'initialPage': pageNumber,
          },
        );
      }
    } catch (e) {
      debugPrint('Error navigating to page: $e');
    }
  }

  String _getSurahNameForPage(int pageNumber) {
    try {
      final pageData = quran.getPageData(pageNumber.clamp(1, 604));
      if (pageData.isNotEmpty) {
        final sNum = pageData[0]['surah'] as int;
        if (sNum >= 1 && sNum <= SurahModel.surahNamesList.length) {
          return SurahModel.surahNamesList[sNum - 1];
        }
      }
    } catch (_) {}
    return '';
  }

  void _showOptionsMenu(BuildContext context, KhatmaModel khatma) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F261D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'خيارات الختمة المباركة',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDarkPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: IslamicStarBadge(
                  size: 38.r,
                  color: AppColors.accentGold,
                  child: const Icon(Icons.edit_note_rounded, color: AppColors.accentGold, size: 20),
                ),
                title: Text(
                  'تعديل خطة الختمة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDarkPrimary,
                  ),
                ),
                subtitle: Text(
                  'تعديل الأيام أو الصفحات وموعد التذكير مع الحفاظ على تقدمك',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.5.sp,
                    color: isDark ? Colors.white60 : AppColors.textDarkMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  final currentKhatma = KhatmaService.activeKhatmaNotifier.value;
                  KhatmaSetupDialog.show(context, existingKhatma: currentKhatma);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restart_alt_rounded, color: AppColors.accentGold, size: 20),
                ),
                title: Text(
                  'بدء ختمة جديدة من البداية',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDarkPrimary,
                  ),
                ),
                subtitle: Text(
                  'تصفير التقدم والبدء في خطة جديدة من الصفحة الأولى',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.5.sp,
                    color: isDark ? Colors.white60 : AppColors.textDarkMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  KhatmaSetupDialog.show(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                ),
                title: Text(
                  'حذف الختمة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                subtitle: Text(
                  'إزالة بطاقة الختمة الحالية من الصفحة الرئيسية',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.5.sp,
                    color: isDark ? Colors.white60 : AppColors.textDarkMuted,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await KhatmaService.deleteKhatma();
                  if (context.mounted) {
                    AppSnackBar.showSuccess(
                      context,
                      message: 'تم حذف الختمة بنجاح',
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<KhatmaModel?>(
      valueListenable: KhatmaService.activeKhatmaNotifier,
      builder: (context, khatma, _) {
        if (khatma == null) {
          return _buildSpiritualInvitationCard(context, isDark);
        }
        return _buildActiveKhatmaDashboard(context, khatma, isDark);
      },
    );
  }

  /// 1. Spiritual Invitation Card (عند عدم وجود ختمة نشطة)
  /// Features 3D Luxury Holy Quran Artwork with Gilded Border and Islamic Arabesques
  Widget _buildSpiritualInvitationCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 154.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Photograph
          Positioned.fill(
            child: Image.asset(
              AppAssets.khatmaCardBg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Deep Regal Emerald Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF042117).withValues(alpha: 0.90),
                    const Color(0xFF02120C).withValues(alpha: 0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Subtle Islamic Tessellation Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  strokeColor: AppColors.accentGold,
                  cellSize: 46.r,
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 3D Holy Quran Asset inside a Glowing Star/Circular Frame
                    Container(
                      width: 58.r,
                      height: 58.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withValues(alpha: 0.35),
                            blurRadius: 10,
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

                    // Titles & Calligraphy
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ختمة القرآن الكريم',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 17.sp,
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
                                  border: Border.all(
                                    color: AppColors.accentGold.withValues(alpha: 0.4),
                                    width: 0.7,
                                  ),
                                ),
                                child: Text(
                                  'خطة مباركة',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGoldLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'حدد وردك بالأيام أو الصفحات مع تذكير يومي في موعدك',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Bottom Action Bar: Feature badges + Start Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Feature Badges
                    Row(
                      children: [
                        _buildFeaturePill(icon: Icons.calendar_month_rounded, text: 'بالأيام أو الصفحات'),
                        SizedBox(width: 6.w),
                        _buildFeaturePill(icon: Icons.access_time_filled_rounded, text: 'تذكير ذكي'),
                      ],
                    ),

                    // Luxury Gold Button
                    GestureDetector(
                      onTap: () => KhatmaSetupDialog.show(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.5.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentGold,
                              Color(0xFFE2B258),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ابدأ الختمة',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14.r),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white24, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: AppColors.accentGoldLight),
          SizedBox(width: 3.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 10.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Active Khatma Dashboard Card (لوحة متابعة الختمة النشطة الفاخرة)
  Widget _buildActiveKhatmaDashboard(BuildContext context, KhatmaModel khatma, bool isDark) {
    final (startP, endP) = khatma.todayWirdRange;
    final pagesInWird = endP - startP + 1;
    final isDone = khatma.isTodayWirdDone;

    final startSurah = _getSurahNameForPage(startP);
    final endSurah = _getSurahNameForPage(endP);
    final surahRangeText = (startSurah.isNotEmpty && endSurah.isNotEmpty)
        ? (startSurah == endSurah ? 'سورة $startSurah' : 'من سورة $startSurah إلى سورة $endSurah')
        : '';

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDone
              ? const Color(0xFF48B682).withValues(alpha: 0.6)
              : AppColors.accentGold.withValues(alpha: 0.6),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Photograph
          Positioned.fill(
            child: Image.asset(
              AppAssets.khatmaCardBg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Deep Regal Emerald Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF042117).withValues(alpha: 0.90),
                    const Color(0xFF02120C).withValues(alpha: 0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Subtle Islamic Tessellation Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  strokeColor: AppColors.accentGold,
                  cellSize: 48.r,
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header: 3D Emblem Avatar, Title Pill, Day Counter, More Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 3D Holy Quran Miniature Avatar
                        Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentGold, width: 1.2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppAssets.khatmaIconLuxury,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.accentGold.withValues(alpha: 0.45),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            khatma.title,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.5.sp,
                              color: AppColors.accentGoldLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'اليوم ${QuranMetadata.toArabicDigits(khatma.currentDayNumber)} من ${QuranMetadata.toArabicDigits(khatma.targetDays)}',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showOptionsMenu(context, khatma),
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.accentGoldLight,
                          size: 18.r,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Center Section: Wird Info & Surahs
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: (isDone ? const Color(0xFF48B682) : AppColors.accentGold)
                            .withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone ? Icons.check_circle_rounded : Icons.auto_stories_rounded,
                        size: 18.r,
                        color: isDone ? const Color(0xFF86E2A3) : AppColors.accentGoldLight,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDone
                                ? 'أتممت وِرد اليوم بنجاح 🌿'
                                : (surahRangeText.isNotEmpty
                                    ? surahRangeText
                                    : 'وِرد اليوم المبارك'),
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDone ? const Color(0xFF86E2A3) : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isDone
                                ? 'وصلت لصفحة ${QuranMetadata.toArabicDigits(khatma.currentPage)} من ٦٠٤'
                                : 'صـ ${QuranMetadata.toArabicDigits(startP)} إلى ${QuranMetadata.toArabicDigits(endP)} · ($pagesInWird صفحة اليوم)',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.5.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        isDone
                            ? 'مُكتمل ✓'
                            : '$pagesInWird صفحة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: isDone ? const Color(0xFF86E2A3) : AppColors.accentGoldLight,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Clean & Calm Linear Progress Bar (بدون توهج أو حشو ألوان)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: khatma.progressRatio,
                    minHeight: 5.h,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? const Color(0xFF48B682) : AppColors.accentGold,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صفحة ${QuranMetadata.toArabicDigits(khatma.currentPage)} من ٦٠٤',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'متبقي ${QuranMetadata.toArabicDigits(khatma.remainingPages)} صفحة · ${QuranMetadata.toArabicDigits(khatma.remainingDays)} يوماً',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11.sp,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Bottom Action Buttons
                if (isDone) ...[
                  if (khatma.isCompleted) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF143B2A),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFF48B682), width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.accentGoldLight, size: 18),
                          SizedBox(width: 8.w),
                          Text(
                            'مبارك لك ختم كتاب الله كاملاً! 🌿',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Completed Status Bar
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF143B2A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFF48B682).withValues(alpha: 0.7), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF48B682), size: 15),
                          SizedBox(width: 6.w),
                          Text(
                            'أتممت وِرد اليوم بنجاح · تقبل الله طاعتك 🌿',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF86E2A3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Option to read ahead / next wird
                    Builder(
                      builder: (ctx) {
                        final (nextStart, nextEnd) = khatma.nextWirdRange;
                        final nextRangeStr = nextStart == nextEnd
                            ? 'صـ ${QuranMetadata.toArabicDigits(nextStart)}'
                            : 'صـ ${QuranMetadata.toArabicDigits(nextStart)} إلى ${QuranMetadata.toArabicDigits(nextEnd)}';
                        return Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openPage(context, nextStart),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: Colors.white24, width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.menu_book_rounded, size: 14, color: Colors.white70),
                                      SizedBox(width: 5.w),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'اقرأ الوِرد التالي ($nextRangeStr)',
                                            style: TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () async {
                                await KhatmaService.completeTodayWird(nextEnd);
                                if (context.mounted) {
                                  AppSnackBar.showSuccess(
                                    context,
                                    message: 'هنيئاً لك! تم تسجيل إتمام الوِرد التالي ($nextRangeStr) متقدماً في ختمتك 🌙',
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColors.accentGold.withValues(alpha: 0.6),
                                    width: 0.9,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.done_all_rounded,
                                        size: 14.r, color: AppColors.accentGoldLight),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'أتممت التالي',
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentGoldLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ] else ...[
                  // Active: Primary Read Button + Mark Complete Button
                  Row(
                    children: [
                      // Primary Button: Open Page
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openPage(context, startP),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.accentGold,
                                  Color(0xFFE2B258),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentGold.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 6.w),
                                Text(
                                  'اقرأ وِرد اليوم ($pagesInWird صفحة)',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Secondary Button: Mark Complete
                      GestureDetector(
                        onTap: () async {
                          await KhatmaService.completeTodayWird();
                          if (context.mounted) {
                            AppSnackBar.showSuccess(
                              context,
                              message: 'هنيئاً لك! تم تسجيل إتمام وِرد اليوم بنجاح 🌿',
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.accentGold.withValues(alpha: 0.55),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.done_all_rounded,
                                  size: 15.r, color: AppColors.accentGoldLight),
                              SizedBox(width: 4.w),
                              Text(
                                'أتممته',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGoldLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
