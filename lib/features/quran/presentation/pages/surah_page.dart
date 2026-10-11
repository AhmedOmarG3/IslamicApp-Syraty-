import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/services/mushaf_page_service.dart';
import 'package:siraty/features/quran/presentation/cubit/mushaf_settings_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/widgets/ayah_options_sheet.dart';
import 'package:siraty/features/quran/presentation/widgets/madinah_quran_page_view.dart';
import 'package:siraty/features/quran/presentation/widgets/mushaf_highlight.dart';
import 'package:siraty/features/quran/presentation/widgets/mushaf_theme_palette.dart';
import 'package:siraty/features/quran/presentation/widgets/reading_settings_sheet.dart';
import 'package:siraty/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';

/// Authentic Madinah Mushaf reader page powered by King Fahd Complex QCF fonts.
///
/// Features:
/// - Exact 1:1 printed Madinah Mushaf layout (15 lines per page, 604 pages, Hafs narration).
/// - Reading paper themes (Cream, Night, Sepia) via [MushafSettingsCubit].
/// - Smooth Pinch-to-Zoom with smart reset and authentic 15-line layout preservation.
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
  late int _activeSurahNumber;
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
      _selectedSurah = widget.surah.surahNumber;
      _selectedAyah = widget.targetAyah;
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
      // Explicit target ayah requested (e.g. from Home "متابعة القراءة" banner)
      targetPage = MushafPageService.getPageNumber(
        widget.surah.surahNumber,
        widget.targetAyah!,
      );
    } else {
      // When opening from Surah Index, always start from beginning of Surah (Ayah 1)
      targetPage = MushafPageService.getPageNumber(widget.surah.surahNumber, 1);
    }

    _currentPageNumber = targetPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPageNumber - 1);

    // 3. Initialize active surah: if the page contains widget.surah, prioritize it!
    final initialSurahs = _getSurahsOnPage(_currentPageNumber);
    if (initialSurahs.contains(widget.surah.surahNumber)) {
      _activeSurahNumber = widget.surah.surahNumber;
    } else if (initialSurahs.isNotEmpty) {
      _activeSurahNumber = initialSurahs.first;
    } else {
      _activeSurahNumber = widget.surah.surahNumber;
    }

    // Ensure PageController is aligned to expected page after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        final expected = _currentPageNumber - 1;
        if (_pageController.page?.round() != expected) {
          _pageController.jumpToPage(expected);
        }
      }
    });

    // 4. Auto-open Tafsir sheet if requested
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

  List<int> _getSurahsOnPage(int pageNumber) {
    final pageData = quran.getPageData(pageNumber);
    final List<int> list = [];
    for (final item in pageData) {
      final int s = item['surah'] as int;
      if (!list.contains(s)) {
        list.add(s);
      }
    }
    return list;
  }

  String _getSurahNameByNumber(int surahNum) {
    if (surahNum >= 1 && surahNum <= SurahModel.surahNamesList.length) {
      return SurahModel.surahNamesList[surahNum - 1];
    }
    return widget.surahName;
  }

  void _handlePageChanged(int pageIndex) {
    final pageNumber = pageIndex < 1 ? pageIndex + 1 : (pageIndex <= 604 ? pageIndex : 604);
    if (_currentPageNumber == pageNumber) return;

    final surahsOnPage = _getSurahsOnPage(pageNumber);
    int newActiveSurah = _activeSurahNumber;
    if (!surahsOnPage.contains(_activeSurahNumber)) {
      newActiveSurah = surahsOnPage.isNotEmpty ? surahsOnPage.first : _activeSurahNumber;
    }

    setState(() {
      _currentPageNumber = pageNumber;
      _activeSurahNumber = newActiveSurah;
    });

    // Update Quran resume banner index without corrupting the user's explicit saved bookmark
    context.read<QuranCubit>().updateLastRead(newActiveSurah - 1);
  }

  int _getPrimarySurahNum() {
    final surahsOnPage = _getSurahsOnPage(_currentPageNumber);
    if (surahsOnPage.contains(_activeSurahNumber)) {
      return _activeSurahNumber;
    }
    if (surahsOnPage.isNotEmpty) {
      return surahsOnPage.first;
    }
    return _activeSurahNumber;
  }

  String _getCurrentSurahName() {
    return _getSurahNameByNumber(_getPrimarySurahNum());
  }

  int _getCurrentJuz() {
    final pageData = quran.getPageData(_currentPageNumber);
    if (pageData.isNotEmpty) {
      final int s0 = pageData.first['surah'] as int;
      final int a0 = pageData.first['start'] as int;
      return quran.getJuzNumber(s0, a0);
    }
    return 1;
  }

  void _onAyahTapped(int surahNumber, int verseNumber) {
    setState(() {
      _selectedSurah = surahNumber;
      _selectedAyah = verseNumber;
      _activeSurahNumber = surahNumber;
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
                  final audioPage = MushafPageService.getPageNumber(sNum, aNum);
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
            final List<MushafHighlight> activeHighlights = [];

            // 1. Saved Bookmark / Last Read Highlight (العلامة المحفوظة لتسهيل العودة)
            if (_bookmarkedSurah != null && _bookmarkedAyah != null) {
              activeHighlights.add(
                MushafHighlight(
                  surah: _bookmarkedSurah!,
                  verseNumber: _bookmarkedAyah!,
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
                  activeHighlights.add(
                    MushafHighlight(
                      surah: sNum,
                      verseNumber: aNum,
                      color: AppColors.accentGold.withValues(alpha: 0.35),
                    ),
                  );
                }
              }
            }

            // 3. User tapped/selected verse highlight
            if (_selectedSurah != null && _selectedAyah != null) {
              activeHighlights.add(
                MushafHighlight(
                  surah: _selectedSurah!,
                  verseNumber: _selectedAyah!,
                  color: AppColors.accentGold.withValues(alpha: 0.45),
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: scaffoldBg,
                resizeToAvoidBottomInset: false,
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
                                          Builder(
                                            builder: (ctx) {
                                              final surahs = _getSurahsOnPage(_currentPageNumber);
                                              if (surahs.length > 1) {
                                                return PopupMenuButton<int>(
                                                  tooltip: 'اختيار السورة من الصفحة',
                                                  color: AppColors.cardDarkElevated,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(14.r),
                                                    side: const BorderSide(color: AppColors.borderGold, width: 0.8),
                                                  ),
                                                  initialValue: _getPrimarySurahNum(),
                                                  onSelected: (int sNum) {
                                                    setState(() {
                                                      _activeSurahNumber = sNum;
                                                    });
                                                  },
                                                  itemBuilder: (ctx) => surahs.map((sNum) {
                                                    final isCurrent = sNum == _getPrimarySurahNum();
                                                    return PopupMenuItem<int>(
                                                      value: sNum,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'سورة ${_getSurahNameByNumber(sNum)}',
                                                            style: TextStyle(
                                                              fontFamily: 'AmiriQuran',
                                                              fontSize: 14.sp,
                                                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                                              color: isCurrent ? AppColors.accentGold : AppColors.textWhite,
                                                            ),
                                                          ),
                                                          if (isCurrent)
                                                            const Icon(Icons.check_rounded, color: AppColors.accentGold, size: 18),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
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
                                                      const SizedBox(width: 2),
                                                      const Icon(
                                                        Icons.keyboard_arrow_down_rounded,
                                                        color: AppColors.accentGold,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              return Text(
                                                _getCurrentSurahName(),
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontFamily: 'AmiriQuran',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
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
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'وضع ملء الشاشة: انقر مرتين على الشاشة لإظهار القوائم مجدداً',
                                              textAlign: TextAlign.center,
                                            ),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
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
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: () {
                            setState(() {
                              _isHeaderVisible = !_isHeaderVisible;
                            });
                          },
                          child: MadinahQuranPageView(
                            pageController: _pageController,
                            isFullScreen: !_isHeaderVisible,
                            highlights: activeHighlights,
                            pageBackgroundColor: bgColor,
                            textColor: textColor,
                            verseNumberColor: isDarkTheme
                                ? AppColors.accentGoldLight
                                : const Color(0xFF8B4513),
                            basmalaColor: textColor,
                            // The surah header plate is a fixed-colour gold
                            // image, so its inscription stays dark brown in
                            // every paper theme — a light colour would vanish
                            // against the plate in night mode.
                            headerTextColor: const Color(0xFF5A4520),
                            onPageChanged: _handlePageChanged,
                            onTap: _onAyahTapped,
                            onLongPress: _onAyahTapped,
                            topBarBuilder: (ctx, page) {
                            final pNum = page < 1 ? page + 1 : (page <= 604 ? page : 604);
                            final pData = quran.getPageData(pNum);
                            int juzNum = 1;
                            String sName = _getSurahNameByNumber(_getPrimarySurahNum());
                            if (pData.isNotEmpty) {
                              final int s0 = pData.first['surah'] as int;
                              final int a0 = pData.first['start'] as int;
                              juzNum = quran.getJuzNumber(s0, a0);
                              sName = (pNum == _currentPageNumber)
                                  ? _getSurahNameByNumber(_getPrimarySurahNum())
                                  : _getSurahNameByNumber(s0);
                            }

                            final headerColor = isDarkTheme
                                ? AppColors.accentGoldLight
                                : const Color(0xFF9E8565);

                            return Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    QuranMetadata.getJuzNameFromNumber(juzNum),
                                    style: TextStyle(
                                      color: headerColor,
                                      fontFamily: 'AmiriQuran',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    sName,
                                    style: TextStyle(
                                      color: headerColor,
                                      fontFamily: 'AmiriQuran',
                                      fontSize: 14,
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
                              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDarkTheme
                                          ? AppColors.accentGold.withValues(alpha: 0.5)
                                          : const Color(0xFFC8A25A).withValues(alpha: 0.65),
                                      width: 1.0,
                                    ),
                                    color: isDarkTheme
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : const Color(0xFFC8A25A).withValues(alpha: 0.08),
                                  ),
                                  child: Text(
                                    QuranMetadata.toArabicDigits(pNum),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    strutStyle: const StrutStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 12.5,
                                      height: 1.1,
                                      forceStrutHeight: true,
                                    ),
                                    style: TextStyle(
                                      color: isDarkTheme ? AppColors.accentGoldLight : const Color(0xFF6B5839),
                                      fontFamily: 'Amiri',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
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

                      // Bottom quick page flip bar (hidden when mini player is active to preserve Quran page space)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: (_isHeaderVisible &&
                                !audioState.isPlaying &&
                                audioState.activeAyah == null)
                            ? 38
                            : 0,
                        child: (_isHeaderVisible &&
                                !audioState.isPlaying &&
                                audioState.activeAyah == null)
                            ? Container(
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
                              )
                            : const SizedBox.shrink(),
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

