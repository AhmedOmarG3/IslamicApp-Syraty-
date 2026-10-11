import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/repositories/tafsir_repository.dart';

class TafsirBottomSheet extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String verseText;

  const TafsirBottomSheet({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.verseText,
  });

  static void show(
    BuildContext context, {
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String verseText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => TafsirBottomSheet(
        surahNumber: surahNumber,
        surahName: surahName,
        ayahNumber: ayahNumber,
        verseText: verseText,
      ),
    );
  }

  @override
  State<TafsirBottomSheet> createState() => _TafsirBottomSheetState();
}

class _TafsirBottomSheetState extends State<TafsirBottomSheet> {
  TafsirModel? _tafsir;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    final result = await TafsirRepository.instance.getAyahTafsir(
      surahNum: widget.surahNumber,
      ayahNum: widget.ayahNumber,
    );
    if (mounted) {
      setState(() {
        _tafsir = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabicAyah = QuranMetadata.toArabicDigits(widget.ayahNumber);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet Top Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded,
                        color: AppColors.accentGold, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'التفسير الميسر',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.sageGreen),
                  ),
                  child: Text(
                    'سورة ${widget.surahName} · آية $arabicAyah',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ayah Sacred Text Card
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardDarkElevated,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '﴿ ${widget.verseText} ﴾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18.sp,
                          color: const Color(0xFFFBF6EC),
                          height: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Tafsir Content Section
                    if (_isLoading) ...[
                      SizedBox(height: 40.h),
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.accentGold,
                              strokeWidth: 2.5,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'جارٍ تحميل التفسير الميسر...',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ] else if (_tafsir != null &&
                        _tafsir!.tafsirText.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131D19),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.sageGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 14.r, color: AppColors.accentGold),
                                SizedBox(width: 6.w),
                                Text(
                                  'التفسير الميسر:',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              _tafsir!.tafsirText,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 15.sp,
                                color: AppColors.textWhite,
                                height: 2.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Copy Tafsir Button
                      GestureDetector(
                        onTap: () {
                          final shareContent =
                              '﴿ ${widget.verseText} ﴾\n[سورة ${widget.surahName}: $arabicAyah]\n\nالتفسير الميسر:\n${_tafsir!.tafsirText}\n\nتطبيق سِيرتي الإسلامي';
                          Clipboard.setData(ClipboardData(text: shareContent));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم نسخ الآية وتفسيرها بنجاح',
                                style: TextStyle(
                                    fontFamily: 'Amiri', fontSize: 13.sp),
                              ),
                              backgroundColor: AppColors.cardHighlight,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.cardDarkElevated,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.copy_rounded,
                                  size: 18.r, color: AppColors.accentGold),
                              SizedBox(width: 8.w),
                              Text(
                                'نسخ الآية مع التفسير',
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
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30.h),
                          child: Column(
                            children: [
                              Icon(Icons.menu_book_rounded,
                                  color: AppColors.textMuted, size: 36.r),
                              SizedBox(height: 10.h),
                              Text(
                                'تعذر عرض التفسير، يرجى المحاولة مرة أخرى.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 13.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
