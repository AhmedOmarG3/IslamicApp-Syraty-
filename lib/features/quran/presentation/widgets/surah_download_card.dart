import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/app_snack_bar.dart';
import 'package:siraty/features/quran/data/services/quran_download_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_download_cubit.dart';

class SurahDownloadCard extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  final int versesCount;
  final bool isDark;

  const SurahDownloadCard({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.versesCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final audioCubit = context.watch<QuranAudioCubit>();
    final downloadCubit = context.watch<QuranDownloadCubit>();
    final reciter = audioCubit.state.selectedReciter;

    final progress = downloadCubit.getSurahProgress(
      reciterId: reciter.id,
      surahNum: surahNumber,
      totalAyahs: versesCount,
    );

    final isDownloading = progress.isDownloading;
    final isFullyDownloaded = progress.isFullyDownloaded;
    final isFailed = progress.isFailed;
    final completed = progress.completedAyahs;

    final Color borderColor = isFailed
        ? const Color(0xFFE74C3C)
        : isFullyDownloaded
            ? AppColors.emeraldGreen.withValues(alpha: 0.6)
            : isDownloading
                ? AppColors.accentGold.withValues(alpha: 0.6)
                : isDark
                    ? AppColors.borderSubtle
                    : AppColors.borderLight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFailed
                      ? const Color(0xFFE74C3C).withValues(alpha: 0.15)
                      : isFullyDownloaded
                          ? AppColors.emeraldGreen.withValues(alpha: 0.15)
                          : isDownloading
                              ? AppColors.accentGold.withValues(alpha: 0.15)
                              : AppColors.cardHighlight,
                ),
                child: Icon(
                  isFailed
                      ? Icons.error_outline_rounded
                      : isFullyDownloaded
                          ? Icons.offline_pin_rounded
                          : isDownloading
                              ? Icons.downloading_rounded
                              : completed > 0
                                  ? Icons.pause_circle_outline_rounded
                                  : Icons.cloud_download_rounded,
                  size: 20.r,
                  color: isFailed
                      ? const Color(0xFFE74C3C)
                      : isFullyDownloaded
                          ? AppColors.emeraldGreen
                          : AppColors.accentGold,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFailed
                          ? 'تعذر التنزيل، تحقق من الاتصال'
                          : isFullyDownloaded
                              ? 'السورة محملة بالكامل دون إنترنت'
                              : isDownloading
                                  ? 'جارٍ تنزيل سورة $surahName...'
                                  : completed > 0
                                      ? 'تنزيل غير مكتمل ($completed من $versesCount آية)'
                                      : 'تنزيل السورة للاستماع دون إنترنت',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isFailed
                            ? const Color(0xFFFF6B6B)
                            : isDark
                                ? AppColors.textWhite
                                : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isFailed && progress.errorMessage != null
                          ? progress.errorMessage!
                          : 'بصوت ${reciter.name}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11.sp,
                        color: isFailed ? const Color(0xFFE57373) : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDownloading)
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                  tooltip: 'إلغاء التنزيل',
                  onPressed: () {
                    downloadCubit.cancelSurahDownload(
                      reciterId: reciter.id,
                      surahNum: surahNumber,
                    );
                    AppSnackBar.showInfo(context, message: 'تم إيقاف التنزيل');
                  },
                )
              else if (isFullyDownloaded)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'حذف التنزيل لتوفير المساحة',
                  onPressed: () => _confirmDeleteSurah(context, reciter.id, reciter.name),
                )
              else
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: (isFailed ? const Color(0xFFE74C3C) : AppColors.accentGold)
                        .withValues(alpha: 0.15),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    isFailed
                        ? Icons.refresh_rounded
                        : completed > 0
                            ? Icons.play_arrow_rounded
                            : Icons.download_rounded,
                    size: 16.r,
                    color: isFailed ? const Color(0xFFE74C3C) : AppColors.accentGold,
                  ),
                  label: Text(
                    isFailed
                        ? 'إعادة'
                        : completed > 0
                            ? 'استكمال'
                            : 'تنزيل',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isFailed ? const Color(0xFFE74C3C) : AppColors.accentGold,
                    ),
                  ),
                  onPressed: () {
                    AppSnackBar.showInfo(
                      context,
                      message: 'بدأ تنزيل سورة $surahName بصوت ${reciter.name}...',
                    );
                    downloadCubit.startSurahDownload(
                      reciterId: reciter.id,
                      surahNum: surahNumber,
                      totalAyahs: versesCount,
                    );
                  },
                ),
            ],
          ),
          if (isDownloading) ...[
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: progress.progressFraction,
                backgroundColor: AppColors.cardHighlight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completedAyahs} من $versesCount آية',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 10.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${progress.progressPercent}%',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ] else if (isFullyDownloaded) ...[
            SizedBox(height: 6.h),
            FutureBuilder<int>(
              future: downloadCubit.getSurahSizeBytes(reciter.id, surahNumber),
              builder: (context, snapshot) {
                final bytes = snapshot.data ?? 0;
                return Text(
                  'المساحة المستهلكة: ${QuranDownloadService.formatBytes(bytes)}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 10.sp,
                    color: AppColors.emeraldGreen,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDeleteSurah(BuildContext context, String reciterId, String reciterName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'حذف التنزيل',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف التنزيل المحلي لسورة $surahName بصوت $reciterName لتوفير المساحة؟ يمكنك تنزيلها مجدداً في أي وقت.',
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
                    reciterId: reciterId,
                    surahNum: surahNumber,
                  );
              if (context.mounted) {
                AppSnackBar.showInfo(
                  context,
                  message: 'تم حذف التنزيل المحلي لسورة $surahName',
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
