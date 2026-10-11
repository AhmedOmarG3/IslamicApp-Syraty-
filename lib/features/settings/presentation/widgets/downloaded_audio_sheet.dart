import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_snack_bar.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/services/quran_download_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_download_cubit.dart';

/// Modal bottom sheet presenting a comprehensive breakdown of all downloaded
/// Quran surahs, reciter names, ayahs count/ranges, and disk space with
/// granular per-surah deletion and global clear operations.
class DownloadedAudioSheet extends StatelessWidget {
  const DownloadedAudioSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<QuranDownloadCubit>(),
        child: const DownloadedAudioSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final downloadCubit = context.watch<QuranDownloadCubit>();

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 42.w,
                height: 4.5.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),

            // Sheet Title & Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sd_storage_rounded,
                        color: AppColors.accentGold,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'التلاوات المحملة دون إنترنت',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5.sp,
                        color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                    size: 22.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Content Body
            Expanded(
              child: FutureBuilder<List<DownloadedSurahDetail>>(
                future: downloadCubit.getDownloadedSurahsDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accentGold),
                    );
                  }

                  final list = snapshot.data ?? [];

                  if (list.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }

                  final totalBytes = list.fold<int>(0, (sum, item) => sum + item.sizeBytes);
                  final formattedTotal = QuranDownloadService.formatBytes(totalBytes);

                  return Column(
                    children: [
                      // Header Summary Card (Total Storage & Clear All)
                      _buildHeaderSummaryCard(
                        context,
                        isDark,
                        totalSurahs: list.length,
                        formattedTotalSize: formattedTotal,
                      ),
                      SizedBox(height: 14.h),

                      // Section Label
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'قائمة السور المحملة (${QuranMetadata.toArabicDigits(list.length)})',
                          style: AppTextStyles.caption.copyWith(
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5.sp,
                            color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // List of Downloaded Surahs
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            return _buildSurahItemCard(
                              context,
                              list[index],
                              isDark,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withValues(alpha: 0.6)
                    : AppColors.iconBgCircleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_done_rounded,
                size: 54.r,
                color: AppColors.accentGold.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد تلاوات محملة حالياً',
              style: AppTextStyles.titleMedium.copyWith(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'يمكنك تنزيل أي سورة بصوت قارئك المفضل من مشغل التلاوة أو فهرس المصحف للاستماع دون إنترنت في أي وقت.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontFamily: 'Amiri',
                fontSize: 12.5.sp,
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummaryCard(
    BuildContext context,
    bool isDark, {
    required int totalSurahs,
    required String formattedTotalSize,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF07271B)
            : const Color(0xFFF1F6F3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.accentGold.withValues(alpha: 0.3) : AppColors.borderGold.withValues(alpha: 0.4),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pie_chart_outline_rounded,
                  color: AppColors.accentGoldLight,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المساحة الكلية المستهلكة',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 11.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    formattedTotalSize,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDarkPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              side: const BorderSide(color: Colors.redAccent, width: 0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            icon: const Icon(Icons.delete_sweep_rounded, size: 16),
            label: Text(
              'حذف الكل',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            onPressed: () => _confirmClearAll(context, formattedTotalSize, isDark),
          ),
        ],
      ),
    );
  }

  void _playSurah(BuildContext context, DownloadedSurahDetail detail) {
    Navigator.pop(context);
    context.push(
      '/quran-listen',
      extra: {
        'surahNumber': detail.surahNumber,
        'surahName': detail.surahName,
        'versesCount': detail.totalAyahs,
        'reciterId': detail.reciterId,
      },
    );
  }

  Widget _buildSurahItemCard(
    BuildContext context,
    DownloadedSurahDetail detail,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _playSurah(context, detail),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.7,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Surah Number Emblem
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
                ),
                child: Center(
                  child: Text(
                    QuranMetadata.toArabicDigits(detail.surahNumber),
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGoldLight,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Surah & Reciter Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'سورة ${detail.surahName}',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Full/Partial Pill
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: (detail.isFullyDownloaded
                                    ? AppColors.emeraldGreen
                                    : AppColors.accentGold)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            detail.isFullyDownloaded ? 'كاملة ✓' : 'جزئية',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: detail.isFullyDownloaded
                                  ? const Color(0xFF48B682)
                                  : AppColors.accentGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    // Reciter Name
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 12.r, color: isDark ? Colors.white60 : Colors.black45),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            detail.reciterName,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.5.sp,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Ayahs Count & Size Breakdown
                    Row(
                      children: [
                        Text(
                          detail.ayahsDescription,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 11.sp,
                            color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                          ),
                        ),
                        Text(
                          ' · ${detail.formattedSize}',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 11.sp,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions: Play / Open Surah + Delete Surah
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Listen to Surah
                  IconButton(
                    tooltip: 'تشغيل واستماع',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    icon: Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.accentGold,
                      size: 22.r,
                    ),
                    onPressed: () => _playSurah(context, detail),
                  ),

                  // Delete this surah
                  IconButton(
                    tooltip: 'حذف السورة',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent.withValues(alpha: 0.85),
                      size: 19.r,
                    ),
                    onPressed: () => _confirmDeleteSurah(context, detail, isDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSurah(
    BuildContext context,
    DownloadedSurahDetail detail,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'حذف تلاوة سورة ${detail.surahName}',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف التلاوة المحملة لسورة ${detail.surahName} بصوت ${detail.reciterName} وتفريغ مساحة ${detail.formattedSize}؟',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<QuranDownloadCubit>().deleteSurah(
                    reciterId: detail.reciterId,
                    surahNum: detail.surahNumber,
                  );
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  message: 'تم حذف تلاوة سورة ${detail.surahName} بنجاح',
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(
    BuildContext context,
    String formattedTotalSize,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'حذف جميع التلاوات المحملة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيتم حذف جميع السور والآيات المحملة دون إنترنت لجميع القراء وتفريغ مساحة $formattedTotalSize من ذاكرة الهاتف. هل أنت متأكد؟',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<QuranDownloadCubit>().deleteAllDownloads();
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  message: 'تم تفريغ مساحة $formattedTotalSize وحذف جميع التلاوات بنجاح',
                );
              }
            },
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}
