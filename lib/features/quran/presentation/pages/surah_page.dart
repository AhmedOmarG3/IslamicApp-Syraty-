import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:quran/quran.dart' as quran;
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/presentation/cubit/mushaf_settings_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/widgets/ayah_options_sheet.dart';
import 'package:siraty/features/quran/presentation/widgets/mushaf_theme_palette.dart';
import 'package:siraty/features/quran/presentation/widgets/reading_settings_sheet.dart';
import 'package:siraty/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';

/// Authentic Medina Mushaf reader page powered by [QuranPageView] and King Fahd QCF fonts.
///
/// Features:
/// - Exact 1:1 printed Madinah Mushaf layout (15 lines per page, 604 pages, Hafs narration).
/// - Dynamic font sizing and reading paper themes (Cream, Night, Sepia) via [MushafSettingsCubit].
/// - High-contrast luxury Madinah Surah headers for perfect readability in both light & dark modes.
/// - Distinct highlighting for saved bookmark / last-read verse so users easily spot where they left off.
/// - Full Surah audio recitation and verse-by-verse audio tracking with interactive mini player.
/// - Complete Ayah-level interactivity: tap or long-press to open [AyahOptionsSheet].
/// - Fast jump-to-page dialog (1..604) and automated last-read bookmark tracking.
class SurahPage extends StatefulWidget {
  final SurahModel surah;
  final String surahName;
  final int? initialPage;
  final int? targetAyah;
  final bool autoOpenTafsir;

  const SurahPage({
    super.key,
    required this.surah,
    required this.surahName,
    this.initialPage,
    this.targetAyah,
    this.autoOpenTafsir = false,
  });

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  late final PageController _pageController;
  late int _currentPageNumber;
  int? _selectedSurah;
  int? _selectedAyah;
  int? _bookmarkedSurah;
  int? _bookmarkedAyah;
  bool _isHeaderVisible = true;

  @override
  void initState() {
    super.initState();

    // 1. Initialize bookmarked/saved ayah from targetAyah or LastReadService
    if (widget.targetAyah != null) {
      _bookmarkedSurah = widget.surah.surahNumber;
      _bookmarkedAyah = widget.targetAyah;
    } else {
      final lastRead = LastReadService.lastReadNotifier.value;
      if (lastRead != null && lastRead.surahNumber == widget.surah.surahNumber) {
        _bookmarkedSurah = lastRead.surahNumber;
        _bookmarkedAyah = lastRead.ayahNumber;
      }
    }

    // 2. Determine initial 1-indexed page (1..604)
    int targetPage = 1;
    if (widget.initialPage != null &&
        widget.initialPage! >= 1 &&
        widget.initialPage! <= 604) {
      targetPage = widget.initialPage!;
    } else if (widget.targetAyah != null) {
      targetPage = quran.getPageNumber(
        widget.surah.surahNumber,
        widget.targetAyah!,
      );
    } else if (_bookmarkedAyah != null) {
      targetPage = quran.getPageNumber(
        widget.surah.surahNumber,
        _bookmarkedAyah!,
      );
    } else {
      final pages = quran.getSurahPages(widget.surah.surahNumber);
      targetPage = pages.isNotEmpty ? pages.first : 1;
    }

    _currentPageNumber = targetPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPageNumber - 1);

    // 3. Auto-open Tafsir sheet if requested
    if (widget.autoOpenTafsir && widget.targetAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        TafsirBottomSheet.show(
          context,
          surahNumber: widget.surah.surahNumber,
          surahName: widget.surahName,
          ayahNumber: widget.targetAyah!,
          verseText: quran.getVerse(
            widget.surah.surahNumber,
            widget.targetAyah!,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int pageIndex) {
    final pageNumber = pageIndex < 1 ? pageIndex + 1 : (pageIndex <= 604 ? pageIndex : 604);
    if (_currentPageNumber == pageNumber) return;

    setState(() {
      _currentPageNumber = pageNumber;
    });

    final pageData = quran.getPageData(pageNumber);
    if (pageData.isNotEmpty) {
      final int primarySurahNum = pageData.first['surah'] as int;
      final int primaryAyahNum = pageData.first['start'] as int;
      final String primarySurahName =
          (primarySurahNum >= 1 && primarySurahNum <= SurahModel.surahNamesList.length)
              ? SurahModel.surahNamesList[primarySurahNum - 1]
              : widget.surahName;

      LastReadService.saveLastRead(
        surahNumber: primarySurahNum,
        surahName: primarySurahName,
        ayahNumber: primaryAyahNum,
      );

      context.read<QuranCubit>().updateLastRead(primarySurahNum - 1);
    }
  }

  int _getPrimarySurahNum() {
    final pageData = quran.getPageData(_currentPageNumber);
    if (pageData.isNotEmpty) {
      return pageData.first['surah'] as int;
    }
    return widget.surah.surahNumber;
  }

  String _getCurrentSurahName() {
    final int sNum = _getPrimarySurahNum();
    if (sNum >= 1 && sNum <= SurahModel.surahNamesList.length) {
      return SurahModel.surahNamesList[sNum - 1];
    }
    return widget.surahName;
  }

  int _getCurrentJuz() {
    final pageData = quran.getPageData(_currentPageNumber);
    if (pageData.isNotEmpty) {
      final int sNum = pageData.first['surah'] as int;
      final int aNum = pageData.first['start'] as int;
      return quran.getJuzNumber(sNum, aNum);
    }
    return 1;
  }

  void _onAyahTapped(int surahNumber, int verseNumber) {
    setState(() {
      _selectedSurah = surahNumber;
      _selectedAyah = verseNumber;
    });

    final String sName = (surahNumber >= 1 && surahNumber <= SurahModel.surahNamesList.length)
        ? SurahModel.surahNamesList[surahNumber - 1]
        : widget.surahName;
    final int vCount = quran.getVerseCount(surahNumber);
    final String vText = quran.getVerse(surahNumber, verseNumber);

    AyahOptionsSheet.show(
      context,
      surahNumber: surahNumber,
      surahName: sName,
      versesCount: vCount,
      ayahNumber: verseNumber,
      verseText: vText,
      onBookmark: (ayah) {
        // Save bookmark and update highlight immediately
        LastReadService.saveLastRead(
          surahNumber: surahNumber,
          surahName: sName,
          ayahNumber: ayah,
        );
        context.read<QuranCubit>().updateLastRead(surahNumber - 1);
        if (mounted) {
          setState(() {
            _bookmarkedSurah = surahNumber;
            _bookmarkedAyah = ayah;
          });
        }
      },
      onDismissed: () {
        if (mounted) {
          setState(() {
            _selectedSurah = null;
            _selectedAyah = null;
          });
        }
      },
    );
  }

  void _togglePlayCurrentSurah(QuranAudioState audioState) {
    final int primarySurahNum = _getPrimarySurahNum();
    final int versesCount = quran.getVerseCount(primarySurahNum);
    final String sName = _getCurrentSurahName();

    if (audioState.isPlaying && audioState.surahNumber == primarySurahNum) {
      context.read<QuranAudioCubit>().pause();
    } else if (!audioState.isPlaying && audioState.surahNumber == primarySurahNum && audioState.activeAyah != null) {
      context.read<QuranAudioCubit>().resume();
    } else {
      context.read<QuranAudioCubit>().playSurah(
        surahNum: primarySurahNum,
        versesCount: versesCount,
        surahName: sName,
      );
    }
  }

  void _showReadingSettings() {
    ReadingSettingsSheet.show(
      context,
      onToggleFullScreen: () {
        setState(() {
          _isHeaderVisible = !_isHeaderVisible;
        });
      },
    );
  }

  void _showPageJumpDialog() {
    final TextEditingController textController =
        TextEditingController(text: _currentPageNumber.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderGold, width: 0.8),
            ),
            title: const Text(
              'الانتقال إلى صفحة',
              style: TextStyle(
                color: AppColors.accentGold,
                fontFamily: 'AmiriQuran',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'أدخل رقم الصفحة من 1 إلى 604:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: AppColors.bgDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.accentGold),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: AppColors.bgDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final target = int.tryParse(textController.text.trim());
                  if (target != null && target >= 1 && target <= 604) {
                    Navigator.of(ctx).pop();
                    _pageController.jumpToPage(target - 1);
                  }
                },
                child: const Text('انتقال', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMadinahSurahHeader(BuildContext context, int surahNumber, bool isDark) {
    final String sName = (surahNumber >= 1 && surahNumber <= SurahModel.surahNamesList.length)
        ? SurahModel.surahNamesList[surahNumber - 1]
        : quran.getSurahNameArabic(surahNumber);
    final int count = quran.getVerseCount(surahNumber);
    final bool isMakki = QuranMetadata.isMakki(surahNumber);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentGold,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : const Color(0x12000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'آياتها ${QuranMetadata.toArabicDigits(count)}',
            style: TextStyle(
              color: isDark ? AppColors.accentGoldLight : AppColors.textDarkMuted,
              fontFamily: 'AmiriQuran',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'سُورَةُ $sName',
            style: const TextStyle(
              color: AppColors.accentGold,
              fontFamily: 'AmiriQuran',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isMakki ? 'مَكِّيَّة' : 'مَدَنِيَّة',
            style: TextStyle(
              color: isDark ? AppColors.accentGoldLight : AppColors.textDarkMuted,
              fontFamily: 'AmiriQuran',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMadinahBasmallah(BuildContext context, int surahNumber, bool isDark) {
    if (surahNumber == 9 || surahNumber == 1) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: 18,
            color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MushafSettingsCubit, MushafSettingsState>(
      builder: (context, mushafSettings) {
        final palette = mushafSettings.themeMode;
        final isDarkTheme = palette == MushafThemeMode.night;
        final bgColor = palette.backgroundColor;
        final scaffoldBg = palette.scaffoldBackgroundColor;
        final textColor = palette.textColor;
        final borderColor = palette.borderColor;
        final headerCardColor = palette.headerCardColor;

        return BlocConsumer<QuranAudioCubit, QuranAudioState>(
          listener: (context, audioState) {
            // Automatically turn page if audio advances to a verse on another page
            if (audioState.currentPlayingKey != null) {
              final parts = audioState.currentPlayingKey!.split(':');
              if (parts.length == 2) {
                final sNum = int.tryParse(parts[0]);
                final aNum = int.tryParse(parts[1]);
                if (sNum != null && aNum != null) {
                  final audioPage = quran.getPageNumber(sNum, aNum);
                  if (audioPage != _currentPageNumber && _pageController.hasClients) {
                    _pageController.animateToPage(
                      audioPage - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              }
            }
          },
          builder: (context, audioState) {
            final int primarySurahNum = _getPrimarySurahNum();
            final bool isCurrentSurahPlaying =
                audioState.isPlaying && audioState.surahNumber == primarySurahNum;

            // Collect active highlights
            final List<HighlightVerse> activeHighlights = [];

            // 1. Saved Bookmark / Last Read Highlight (العلامة المحفوظة لتسهيل العودة)
            if (_bookmarkedSurah != null && _bookmarkedAyah != null) {
              final bookmarkPage = quran.getPageNumber(_bookmarkedSurah!, _bookmarkedAyah!);
              activeHighlights.add(
                HighlightVerse(
                  surah: _bookmarkedSurah!,
                  verseNumber: _bookmarkedAyah!,
                  page: bookmarkPage,
                  color: const Color(0xFFC8A25A).withValues(alpha: 0.38),
                ),
              );
            }

            // 2. Audio recitation active verse highlight
            if (audioState.currentPlayingKey != null) {
              final parts = audioState.currentPlayingKey!.split(':');
              if (parts.length == 2) {
                final sNum = int.tryParse(parts[0]);
                final aNum = int.tryParse(parts[1]);
                if (sNum != null && aNum != null) {
                  final audioPage = quran.getPageNumber(sNum, aNum);
                  activeHighlights.add(
                    HighlightVerse(
                      surah: sNum,
                      verseNumber: aNum,
                      page: audioPage,
                      color: AppColors.accentGold.withValues(alpha: 0.35),
                    ),
                  );
                }
              }
            }

            // 3. User tapped/selected verse highlight
            if (_selectedSurah != null && _selectedAyah != null) {
              final selectedPage = quran.getPageNumber(_selectedSurah!, _selectedAyah!);
              activeHighlights.add(
                HighlightVerse(
                  surah: _selectedSurah!,
                  verseNumber: _selectedAyah!,
                  page: selectedPage,
                  color: AppColors.accentGold.withValues(alpha: 0.45),
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: scaffoldBg,
                body: SafeArea(
                  child: Column(
                    children: [
                      // App Bar / Reader Top Controls
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: _isHeaderVisible ? 56 : 0,
                        child: _isHeaderVisible
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: headerCardColor,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: borderColor.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: textColor),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _getCurrentSurahName(),
                                            style: TextStyle(
                                              color: textColor,
                                              fontFamily: 'AmiriQuran',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${QuranMetadata.getJuzNameFromNumber(_getCurrentJuz())} • صفحة ${QuranMetadata.toArabicDigits(_currentPageNumber)}',
                                            style: TextStyle(
                                              color: textColor.withValues(alpha: 0.70),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Play/Pause current surah button
                                    IconButton(
                                      tooltip: isCurrentSurahPlaying ? 'إيقاف التلاوة مؤقتاً' : 'تشغيل السورة كاملة',
                                      icon: Icon(
                                        isCurrentSurahPlaying
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.play_circle_fill_rounded,
                                        color: AppColors.accentGold,
                                        size: 26,
                                      ),
                                      onPressed: () => _togglePlayCurrentSurah(audioState),
                                    ),
                                    // Settings (Reciter, Font Size, Theme)
                                    IconButton(
                                      tooltip: 'إعدادات الخط والثيم',
                                      icon: Icon(Icons.tune_rounded, color: textColor, size: 22),
                                      onPressed: _showReadingSettings,
                                    ),
                                    // Quick Page Jump
                                    IconButton(
                                      tooltip: 'انتقال إلى صفحة',
                                      icon: const Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 22),
                                      onPressed: _showPageJumpDialog,
                                    ),
                                    // Fullscreen toggle
                                    IconButton(
                                      tooltip: 'ملء الشاشة',
                                      icon: Icon(Icons.fullscreen_rounded, color: textColor, size: 24),
                                      onPressed: () {
                                        setState(() {
                                          _isHeaderVisible = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Authentic 15-Line Madinah Mushaf Page View
                      Expanded(
                        child: GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              _isHeaderVisible = !_isHeaderVisible;
                            });
                          },
                          child: QuranPageView(
                            pageController: _pageController,
                            highlights: activeHighlights,
                            pageBackgroundColor: bgColor,
                            ayahStyle: TextStyle(
                              fontSize: mushafSettings.fontSize,
                              color: textColor,
                            ),
                            onPageChanged: _handlePageChanged,
                            onTap: _onAyahTapped,
                            onLongPress: _onAyahTapped,
                            surahHeaderBuilder: (ctx, sNum) =>
                                _buildMadinahSurahHeader(ctx, sNum, isDarkTheme),
                            basmallahBuilder: (ctx, sNum) =>
                                _buildMadinahBasmallah(ctx, sNum, isDarkTheme),
                            topBarBuilder: (ctx, page) {
                              final pNum = page < 1 ? page + 1 : (page <= 604 ? page : 604);
                              final pData = quran.getPageData(pNum);
                              String sName = widget.surahName;
                              int juzNum = 1;
                              if (pData.isNotEmpty) {
                                final int s = pData.first['surah'] as int;
                                final int a = pData.first['start'] as int;
                                juzNum = quran.getJuzNumber(s, a);
                                if (s >= 1 && s <= SurahModel.surahNamesList.length) {
                                  sName = SurahModel.surahNamesList[s - 1];
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      QuranMetadata.getJuzNameFromNumber(juzNum),
                                      style: TextStyle(
                                        color: isDarkTheme ? AppColors.textWhite : textColor.withValues(alpha: 0.75),
                                        fontFamily: 'AmiriQuran',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      sName,
                                      style: const TextStyle(
                                        color: AppColors.accentGold,
                                        fontFamily: 'AmiriQuran',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            bottomBarBuilder: (ctx, page) {
                              final pNum = page < 1 ? page + 1 : (page <= 604 ? page : 604);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Center(
                                  child: Text(
                                    '— ${QuranMetadata.toArabicDigits(pNum)} —',
                                    style: TextStyle(
                                      color: isDarkTheme ? AppColors.textWhite : textColor.withValues(alpha: 0.85),
                                      fontFamily: 'AmiriQuran',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Floating Mini Audio Player (when audio is active)
                      if (audioState.isPlaying || audioState.activeAyah != null)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.cardDarkElevated,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.accentGold.withValues(alpha: 0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7.r),
                                decoration: BoxDecoration(
                                  color: AppColors.sageGreen.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  color: AppColors.accentGold,
                                  size: 18.r,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.push('/quran-listen', extra: {
                                      'surahNumber': primarySurahNum,
                                      'surahName': _getCurrentSurahName(),
                                      'versesCount': quran.getVerseCount(primarySurahNum),
                                      'initialAyah': audioState.activeAyah ?? 1,
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تلاوة ${audioState.selectedReciter.name}',
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          color: AppColors.accentGold,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'آية ${audioState.activeAyah != null ? QuranMetadata.toArabicDigits(audioState.activeAyah!) : '١'} · اضغط لفتح المشغل الكامل',
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          color: AppColors.textMuted,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  audioState.isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_filled_rounded,
                                  color: AppColors.sageGreen,
                                  size: 28.r,
                                ),
                                onPressed: () {
                                  if (audioState.isPlaying) {
                                    context.read<QuranAudioCubit>().pause();
                                  } else {
                                    context.read<QuranAudioCubit>().resume();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textMuted,
                                  size: 18.r,
                                ),
                                onPressed: () => context.read<QuranAudioCubit>().stop(),
                              ),
                            ],
                          ),
                        ),

                      // Bottom quick page flip bar
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: headerCardColor,
                          border: Border(
                            top: BorderSide(
                              color: borderColor.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _currentPageNumber < 604
                                  ? () => _pageController.nextPage(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                      )
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                              label: const Text('الصفحة التالية', style: TextStyle(fontSize: 12)),
                            ),
                            InkWell(
                              onTap: _showPageJumpDialog,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  'صفحة ${QuranMetadata.toArabicDigits(_currentPageNumber)} من ٦٠٤',
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _currentPageNumber > 1
                                  ? () => _pageController.previousPage(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                      )
                                  : null,
                              icon: const Text('الصفحة السابقة', style: TextStyle(fontSize: 12)),
                              label: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
