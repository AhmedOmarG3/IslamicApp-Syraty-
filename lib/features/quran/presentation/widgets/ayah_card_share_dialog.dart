import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class AyahCardShareDialog extends StatefulWidget {
  final String surahName;
  final int ayahNumber;
  final String verseText;

  const AyahCardShareDialog({
    super.key,
    required this.surahName,
    required this.ayahNumber,
    required this.verseText,
  });

  static void show(
    BuildContext context, {
    required String surahName,
    required int ayahNumber,
    required String verseText,
  }) {
    showDialog(
      context: context,
      builder: (_) => AyahCardShareDialog(
        surahName: surahName,
        ayahNumber: ayahNumber,
        verseText: verseText,
      ),
    );
  }

  @override
  State<AyahCardShareDialog> createState() => _AyahCardShareDialogState();
}

class _AyahCardShareDialogState extends State<AyahCardShareDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _shareCardAsImage() async {
    setState(() => _isExporting = true);
    HapticFeedback.lightImpact();

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/ayah_${widget.surahName}_${widget.ayahNumber}.png';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      if (mounted) {
        Navigator.pop(context);
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              '﴿ ${widget.verseText} ﴾\n[سورة ${widget.surahName}: ${QuranMetadata.toArabicDigits(widget.ayahNumber)}]\n\nتطبيق سِيرتي الإسلامي',
          subject: 'آية من القرآن الكريم - سورة ${widget.surahName}',
        );
      }
    } catch (e) {
      debugPrint('Error sharing ayah image card: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabicAyah = QuranMetadata.toArabicDigits(widget.ayahNumber);
    final formattedText =
        '﴿ ${widget.verseText} ﴾ [سورة ${widget.surahName}: $arabicAyah]';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Shareable Ayah Card wrapped in RepaintBoundary
          RepaintBoundary(
            key: _cardKey,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment(0.0, -0.6),
                  radius: 1.25,
                  colors: [
                    Color(0xFF1E4B3D),
                    Color(0xFF13362A),
                    Color(0xFF0C2018),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card Header: Bismillah + Surah Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.accentGold, size: 16.r),
                          SizedBox(width: 6.w),
                          Text(
                            'سُورَةُ ${widget.surahName}',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.cardDarkElevated,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'آية $arabicAyah',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Divider with Arabesque center
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.8,
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(Icons.flare_rounded,
                            size: 14.r, color: AppColors.accentGold),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.8,
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Sacred Ayah Calligraphy Text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      '﴿ ${widget.verseText} ﴾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20.sp,
                        color: const Color(0xFFFBF6EC),
                        height: 2.1,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // Card Footer: Watermark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.spa_rounded,
                          size: 13.r,
                          color: AppColors.accentGold.withValues(alpha: 0.8)),
                      SizedBox(width: 8.w),
                      Text(
                        'تطبيق سِيرتي الإسلامي · رفيقك اليومي',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 11.sp,
                          color: AppColors.accentGold.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // Action Buttons: Share as Image or Copy Text
          Row(
            children: [
              // 1. Share as Image Button
              Expanded(
                child: GestureDetector(
                  onTap: _isExporting ? null : _shareCardAsImage,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentGold,
                          AppColors.accentGold.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isExporting) ...[
                          SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              color: AppColors.bgDark,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'جارٍ التصدير...',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bgDark,
                            ),
                          ),
                        ] else ...[
                          Icon(Icons.share_rounded,
                              color: AppColors.bgDark, size: 18.r),
                          SizedBox(width: 6.w),
                          Text(
                            'مشاركة كبطاقة صورة',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bgDark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // 2. Copy Text Button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: formattedText));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم نسخ الآية الكريمة ومصدرها',
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 13.sp),
                      ),
                      backgroundColor: AppColors.cardHighlight,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardDarkElevated,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Icon(Icons.copy_rounded,
                      color: AppColors.accentGold, size: 20.r),
                ),
              ),
              SizedBox(width: 6.w),

              // 3. Close Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardDarkElevated,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
