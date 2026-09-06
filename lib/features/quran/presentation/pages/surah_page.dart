import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/entities/verse_entity.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/services/quran_audio_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_state.dart';
import 'package:siraty/features/quran/presentation/widgets/ayah_card_share_dialog.dart';
import 'package:siraty/features/quran/presentation/widgets/madinah_ayah_badge.dart';
import 'package:siraty/features/quran/presentation/widgets/madinah_bismillah.dart';
import 'package:siraty/features/quran/presentation/widgets/madinah_mushaf_frame.dart';
import 'package:siraty/features/quran/presentation/widgets/madinah_surah_header.dart';
import 'package:siraty/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';

enum MushafThemeMode { cream, night, sepia }

class SurahPage extends StatefulWidget {
  final SurahModel surah;
  final String surahName;
  final int? initialPage;
  final int? targetAyah;

  const SurahPage({
    super.key,
    required this.surah,
    required this.surahName,
    this.initialPage,
    this.targetAyah,
  });

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  late SurahModel _currentSurah;
  late String _currentSurahName;
  late ScrollController _scrollController;

  // Customization & Readability States: Defaults to the iconic Light Cream Madinah Mushaf
  double _fontSize = 22.0;
  final double _lineHeight = 2.25;
  MushafThemeMode _themeMode = MushafThemeMode.cream; // Initial light design
  int? _highlightedAyahIndex;
  int? _bookmarkedAyahNumber;

  // Fullscreen Immersive Reading Mode
  bool _isFullScreen = false;

  // Cache recognizers for verses to prevent recreate on build
  final Map<int, TapGestureRecognizer> _recognizers = {};

  // Precise GlobalKeys for each Ayah to ensure 100% exact scroll targeting
  final Map<int, GlobalKey> _ayahKeys = {};

  // Double-tap vs single-tap disambiguation timer for Ayah gestures
  Timer? _singleTapTimer;
  int? _lastTappedAyahIndex;

  bool _initializedTheme = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTheme) {
      _initializedTheme = true;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      _themeMode = isDark ? MushafThemeMode.night : MushafThemeMode.cream;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surah;
    _currentSurahName = widget.surahName;
    _scrollController = ScrollController();

    final lastRead = LastReadService.lastReadNotifier.value;
    if (lastRead != null && lastRead.surahNumber == _currentSurah.surahNumber) {
      _bookmarkedAyahNumber = lastRead.ayahNumber;
    }

    if (widget.targetAyah != null) {
      _scrollToAndHighlightAyah(widget.targetAyah!);
    }
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    _scrollController.dispose();
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
    _ayahKeys.clear();
    super.dispose();
  }

  /// Handles double click to show Ayah options, and single click to toggle zoom / full screen mode
  void _onAyahTap(VerseEntity verse, int index) {
    if (_singleTapTimer != null &&
        _singleTapTimer!.isActive &&
        _lastTappedAyahIndex == index) {
      // Double tap detected on the same Ayah -> Open Ayah options modal sheet
      _singleTapTimer!.cancel();
      _singleTapTimer = null;
      _lastTappedAyahIndex = null;
      _showAyahOptions(verse, index);
    } else {
      // First tap -> Start timer. If no second tap follows within 280ms, toggle full screen / zoom mode
      _singleTapTimer?.cancel();
      _lastTappedAyahIndex = index;
      _singleTapTimer = Timer(const Duration(milliseconds: 280), () {
        if (mounted) {
          _toggleFullScreen();
        }
        _lastTappedAyahIndex = null;
      });
    }
  }

  /// Scroll with 100% pixel precision to target Ayah using its GlobalKey & layout box
  void _scrollToAndHighlightAyah(int ayahNum) {
    final index = ayahNum - 1;
    if (index < 0 || index >= _currentSurah.verses.length) return;

    setState(() {
      _highlightedAyahIndex = index;
    });

    void tryScroll([int attempt = 0]) {
      final key = _ayahKeys[ayahNum];
      final ctx = key?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.28,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutCubic,
        );
      } else if (attempt < 8) {
        Future.delayed(Duration(milliseconds: 80 * (attempt + 1)), () {
          if (mounted) {
            tryScroll(attempt + 1);
          }
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tryScroll();
    });
  }

  void _toggleFullScreen() {
    HapticFeedback.selectionClick();
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // Next / Previous Surah Navigation
  void _navigateToSurah(int newSurahNumber) {
    final cubit = context.read<QuranCubit>();
    if (cubit.state is QuranLoaded) {
      final surahs = (cubit.state as QuranLoaded).surahs;
      final targetIndex = newSurahNumber - 1;
      if (targetIndex >= 0 && targetIndex < surahs.length) {
        final newSurah = surahs[targetIndex];
        final newName = newSurah.getSurahName()[targetIndex];

        _singleTapTimer?.cancel();
        _lastTappedAyahIndex = null;
        for (final r in _recognizers.values) {
          r.dispose();
        }
        _recognizers.clear();
        _ayahKeys.clear();
        setState(() {
          _currentSurah = newSurah;
          _currentSurahName = newName;
          _highlightedAyahIndex = null;
        });

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        cubit.updateLastRead(targetIndex);
      }
    }
  }

  // Reading Themes: Cream Ivory (Madinah Paper), Night Obsidian, Sepia Parchment
  Color get _scaffoldBackgroundColor {
    switch (_themeMode) {
      case MushafThemeMode.cream:
        return AppColors.bgLight; // Warm light ivory background
      case MushafThemeMode.night:
        return const Color(0xFF0D1110); // Deep sleek obsidian
      case MushafThemeMode.sepia:
        return const Color(0xFFEDE3D0); // Warm parchment
    }
  }

  Color get _backgroundColor {
    switch (_themeMode) {
      case MushafThemeMode.cream:
        return AppColors.cardLight; // Clean warm ivory paper
      case MushafThemeMode.night:
        return const Color(0xFF131817);
      case MushafThemeMode.sepia:
        return const Color(0xFFF4EBD9);
    }
  }

  Color get _textColor {
    switch (_themeMode) {
      case MushafThemeMode.cream:
        // Rich deep high-contrast Arabic calligraphy black-emerald
        return const Color(0xFF0F1813);
      case MushafThemeMode.night:
        // Crisp, pure, soft warm-white
        return const Color(0xFFF7F8F4);
      case MushafThemeMode.sepia:
        return const Color(0xFF281D10);
    }
  }

  Color get _borderColor {
    switch (_themeMode) {
      case MushafThemeMode.cream:
        // Vibrant luxury Madinah gold
        return AppColors.accentGold;
      case MushafThemeMode.night:
        return const Color(0xFFC7A567);
      case MushafThemeMode.sepia:
        return const Color(0xFFA67C33);
    }
  }

  Color get _headerCardColor {
    switch (_themeMode) {
      case MushafThemeMode.cream:
        return AppColors.cardLightElevated;
      case MushafThemeMode.night:
        return const Color(0xFF1C2421);
      case MushafThemeMode.sepia:
        return const Color(0xFFE6DAC0);
    }
  }

  // Dedicated Reading & Audio Settings Modal (Opened from Top Bar)
  void _openReadingSettingsModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
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
                            icon: const Icon(Icons.close,
                                color: AppColors.textMuted),
                            onPressed: () => Navigator.pop(ctx),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.cardDarkElevated,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<QuranReciter>(
                            value: QuranAudioService.instance.selectedReciter,
                            isExpanded: true,
                            dropdownColor: AppColors.cardDarkElevated,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.accentGold),
                            items: QuranAudioService.availableReciters
                                .map((reciter) {
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
                                QuranAudioService.instance.setReciter(rec);
                                setModalState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 2. Font Size Slider & Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حجم الخط',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14.sp,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.cardDarkElevated,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${QuranMetadata.toArabicDigits(_fontSize.toInt())} نقطة',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13.sp,
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.text_decrease_rounded),
                            color: AppColors.textMuted,
                            onPressed: () {
                              if (_fontSize > 17.0) {
                                setState(() => _fontSize -= 1.0);
                                setModalState(() {});
                              }
                            },
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.accentGold,
                                inactiveTrackColor: AppColors.borderSubtle,
                                thumbColor: AppColors.accentGold,
                                overlayColor:
                                    AppColors.accentGold.withValues(alpha: 0.2),
                                trackHeight: 3.h,
                              ),
                              child: Slider(
                                value: _fontSize,
                                min: 17.0,
                                max: 34.0,
                                divisions: 17,
                                onChanged: (val) {
                                  setState(() => _fontSize = val);
                                  setModalState(() {});
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.text_increase_rounded),
                            color: AppColors.accentGold,
                            onPressed: () {
                              if (_fontSize < 34.0) {
                                setState(() => _fontSize += 1.0);
                                setModalState(() {});
                              }
                            },
                          ),
                        ],
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
                            title: 'ورق المدينة',
                            mode: MushafThemeMode.cream,
                            bgColor: const Color(0xFFFBF6EC),
                            textColor: const Color(0xFF141C18),
                            borderColor: const Color(0xFFBD9346),
                            onTap: () {
                              setState(() => _themeMode = MushafThemeMode.cream);
                              setModalState(() {});
                            },
                          ),
                          SizedBox(width: 8.w),
                          _buildThemeCard(
                            title: 'الوضع الليلي',
                            mode: MushafThemeMode.night,
                            bgColor: const Color(0xFF131817),
                            textColor: const Color(0xFFF7F8F4),
                            borderColor: const Color(0xFFC7A567),
                            onTap: () {
                              setState(() => _themeMode = MushafThemeMode.night);
                              setModalState(() {});
                            },
                          ),
                          SizedBox(width: 8.w),
                          _buildThemeCard(
                            title: 'الوضع الدافئ',
                            mode: MushafThemeMode.sepia,
                            bgColor: const Color(0xFFF4EBD9),
                            textColor: const Color(0xFF281D10),
                            borderColor: const Color(0xFFA67C33),
                            onTap: () {
                              setState(() => _themeMode = MushafThemeMode.sepia);
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),

                      // 4. Fullscreen Mode Quick Trigger Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _toggleFullScreen();
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
                                _isFullScreen
                                    ? Icons.fullscreen_exit_rounded
                                    : Icons.fullscreen_rounded,
                                color: AppColors.accentGold,
                                size: 22.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _isFullScreen
                                    ? 'الخروج من وضع الصفحة الكاملة'
                                    : 'تفعيل وضع الصفحة الكاملة (ملء الشاشة)',
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
          },
        );
      },
    );
  }

  Widget _buildThemeCard({
    required String title,
    required MushafThemeMode mode,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final isSelected = _themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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

  // Ayah Interaction Modal Sheet: Tafsir, Verse Audio, Card Share, Bookmark, Copy
  void _showAyahOptions(VerseEntity verse, int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _highlightedAyahIndex = index;
    });

    final ayahNum = index + 1;
    final arabicAyah = QuranMetadata.toArabicDigits(ayahNum);
    final formattedVerse =
        '﴿ ${verse.text} ﴾ [سورة $_currentSurahName: $arabicAyah]';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayah Header
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.sageGreen, width: 1),
                      ),
                      child: Text(
                        'آية $arabicAyah · سورة $_currentSurahName',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () {
                        setState(() => _highlightedAyahIndex = null);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Ayah Calligraphic Text Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardDarkElevated,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '﴿ ${verse.text} ﴾',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18.sp,
                      color: AppColors.textWhite,
                      height: 1.8,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Action Buttons: 2 Organized Rows of 3 Pillars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. Tafsir (التفسير الميسر)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.menu_book_rounded,
                        label: 'تفسير الآية',
                        onTap: () {
                          Navigator.pop(ctx);
                          TafsirBottomSheet.show(
                            context,
                            surahNumber: _currentSurah.surahNumber,
                            surahName: _currentSurahName,
                            ayahNumber: ayahNum,
                            verseText: verse.text,
                          );
                        },
                      ),
                    ),

                    // 2. Play Single Verse Audio (استماع للآية منفردة)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.volume_up_rounded,
                        label: 'استماع للآية',
                        onTap: () {
                          Navigator.pop(ctx);
                          QuranAudioService.instance.playAyah(
                            surahNum: _currentSurah.surahNumber,
                            ayahNum: ayahNum,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'جارٍ تلاوة الآية $arabicAyah بصوت ${QuranAudioService.instance.selectedReciter.name}',
                                style: TextStyle(
                                    fontFamily: 'Amiri', fontSize: 13.sp),
                              ),
                              backgroundColor: AppColors.cardHighlight,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                    ),

                    // 3. Continue Playing from this Ayah (المتابعة والاستماع من هذه الآية)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.playlist_play_rounded,
                        label: 'المتابعة من هنا',
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push('/quran-listen', extra: {
                            'surahNumber': _currentSurah.surahNumber,
                            'surahName': _currentSurahName,
                            'versesCount': _currentSurah.verses.length,
                            'initialAyah': ayahNum,
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 4. Share as Islamic Image Card (مشاركة كبطاقة)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'بطاقة الآية',
                        onTap: () {
                          Navigator.pop(ctx);
                          AyahCardShareDialog.show(
                            context,
                            surahName: _currentSurahName,
                            ayahNumber: ayahNum,
                            verseText: verse.text,
                          );
                        },
                      ),
                    ),

                    // 5. Bookmark as Last Read (حفظ كعلامة قراءة)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.bookmark_add_rounded,
                        label: 'علامة القراءة',
                        onTap: () {
                          setState(() {
                            _bookmarkedAyahNumber = ayahNum;
                          });
                          LastReadService.saveLastRead(
                            surahNumber: _currentSurah.surahNumber,
                            surahName: _currentSurahName,
                            ayahNumber: ayahNum,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم حفظ الآية $arabicAyah من سورة $_currentSurahName كآخر قراءة',
                                style: TextStyle(
                                    fontFamily: 'Amiri', fontSize: 13.sp),
                              ),
                              backgroundColor: AppColors.accentGold,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),

                    // 6. Copy Formatted Verse (نسخ النص)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.copy_rounded,
                        label: 'نسخ الآية',
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: formattedVerse));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم نسخ الآية الكريمة ومصدرها إلى الحافظة',
                                style: TextStyle(
                                    fontFamily: 'Amiri', fontSize: 13.sp),
                              ),
                              backgroundColor: AppColors.cardHighlight,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() => _highlightedAyahIndex = null);
      }
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.cardDarkElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, color: AppColors.accentGold, size: 20.r),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 11.sp,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahNum = _currentSurah.surahNumber;
    final isMakki = QuranMetadata.isMakki(surahNum);
    final juzName = QuranMetadata.getJuzName(surahNum);
    final verses = _currentSurah.verses;
    final isShortSurah = verses.length <= 8;

    final screenHorizontalPadding = _isFullScreen ? 4.w : 6.w;

    return Scaffold(
      backgroundColor: _scaffoldBackgroundColor,
      // Hide AppBar when in Fullscreen Mode
      appBar: _isFullScreen
          ? null
          : AppHeaderBar(
              title: 'سُورَةُ $_currentSurahName',
              subtitle:
                  '${isMakki ? 'مكية' : 'مدنية'} · ${verses.length} آية · $juzName',
              titleColor: _textColor,
              showBackButton: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full Quran Search Button
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    color: _borderColor,
                    iconSize: 20.r,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'البحث في القرآن الكريم',
                    onPressed: () => context.push('/quran-search'),
                  ),
                  // Audio Recitation Quick Button
                  IconButton(
                    icon: const Icon(Icons.headphones_rounded),
                    color: _borderColor,
                    iconSize: 20.r,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'استماع لتلاوة سورة $_currentSurahName',
                    onPressed: () {
                      final targetAyah =
                          QuranAudioService.instance.activeAyahNotifier.value ??
                              _bookmarkedAyahNumber ??
                              1;
                      context.push('/quran-listen', extra: {
                        'surahNumber': surahNum,
                        'surahName': _currentSurahName,
                        'versesCount': verses.length,
                        'initialAyah': targetAyah,
                      });
                    },
                  ),
                  // Reading Settings Button
                  IconButton(
                    icon: const Icon(Icons.format_size_rounded),
                    color: _borderColor,
                    iconSize: 20.r,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'إعدادات القراءة والمصحف',
                    onPressed: _openReadingSettingsModal,
                  ),
                  // Fullscreen Mode Toggle Button
                  IconButton(
                    icon: const Icon(Icons.fullscreen_rounded),
                    color: _textColor,
                    iconSize: 20.r,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'وضع الصفحة الكاملة',
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
            ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: _toggleFullScreen,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenHorizontalPadding,
              vertical: _isFullScreen ? 4.h : 6.h,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Authentic Madinah Mushaf Frame wrapping the complete Surah
                  MadinahMushafFrame(
                    surahName: _currentSurahName,
                    juzName: juzName,
                    backgroundColor: _backgroundColor,
                    borderColor: _borderColor,
                    headerTextColor: _textColor,
                    isFullScreen: _isFullScreen,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _isFullScreen ? 2.w : 4.w,
                        vertical: isShortSurah ? 16.h : 6.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Decorative Golden Surah Header Plaque
                          MadinahSurahHeader(
                            surahName: _currentSurahName,
                            isMakki: isMakki,
                            versesCount: verses.length,
                            borderColor: _borderColor,
                            backgroundColor: _headerCardColor,
                            textColor: _textColor,
                          ),

                          // 2. Calligraphic Basmala (except Surah At-Tawbah #9)
                          if (surahNum != 9)
                            MadinahBismillah(
                              textColor: _textColor,
                              ornamentColor: _borderColor,
                            ),

                          SizedBox(height: isShortSurah ? 16.h : 8.h),

                          // 3. Complete, Flowing, 100% Guaranteed Non-Truncating Verses
                          Text.rich(
                            TextSpan(
                              children: verses.asMap().entries.map((entry) {
                                final index = entry.key;
                                final verse = entry.value;
                                final ayahNumber = index + 1;
                                final isHighlighted =
                                    _highlightedAyahIndex == index;
                                final isBookmarked =
                                    _bookmarkedAyahNumber == ayahNumber;

                                _recognizers.putIfAbsent(
                                  index,
                                  () => TapGestureRecognizer()
                                    ..onTap =
                                        () => _onAyahTap(verse, index),
                                );

                                final effectiveFontSize = isShortSurah
                                    ? (_fontSize * 1.15)
                                    : _fontSize;
                                final effectiveLineHeight = isShortSurah
                                    ? 2.75
                                    : _lineHeight;

                                return TextSpan(
                                  children: [
                                    // Verse Sacred Text
                                    TextSpan(
                                      text: '${verse.text} ',
                                      recognizer: _recognizers[index],
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: effectiveFontSize.sp,
                                        height: effectiveLineHeight,
                                        color: _textColor,
                                        backgroundColor: isHighlighted
                                            ? _borderColor.withValues(
                                                alpha: 0.35)
                                            : (isBookmarked
                                                ? const Color(0xFFC8A25A)
                                                    .withValues(alpha: 0.28)
                                                : Colors.transparent),
                                      ),
                                    ),

                                    // Inline Madinah Ayah End Rosette with Arabic Numeral
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: KeyedSubtree(
                                        key: _ayahKeys.putIfAbsent(
                                            ayahNumber, () => GlobalKey()),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2.5.w),
                                          child: MadinahAyahBadge(
                                            ayahNumber: ayahNumber,
                                            size: (effectiveFontSize * 1.12)
                                                .clamp(20.0, 36.0),
                                            borderColor: _borderColor,
                                            textColor: _textColor,
                                            onTap: () =>
                                                _onAyahTap(verse, index),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            textAlign: isShortSurah
                                ? TextAlign.center
                                : TextAlign.justify,
                            textDirection: TextDirection.rtl,
                          ),

                          SizedBox(height: isShortSurah ? 24.h : 16.h),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Surah Navigation Bar (Seamless next/previous Surah switcher)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Surah Button (Right in RTL)
                        if (surahNum > 1)
                          GestureDetector(
                            onTap: () => _navigateToSurah(surahNum - 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _headerCardColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: _borderColor.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      size: 12.r, color: _borderColor),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'السورة السابقة',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40),

                        // Surah Completion Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _borderColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: _borderColor.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            'ختام سورة $_currentSurahName',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: _borderColor,
                            ),
                          ),
                        ),

                        // Next Surah Button (Left in RTL)
                        if (surahNum < 114)
                          GestureDetector(
                            onTap: () => _navigateToSurah(surahNum + 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _headerCardColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: _borderColor.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'السورة التالية',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _textColor,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(Icons.arrow_back_ios_rounded,
                                      size: 12.r, color: _borderColor),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: QuranAudioService.instance.isPlayingNotifier,
        builder: (context, isPlaying, _) {
          return ValueListenableBuilder<int?>(
            valueListenable: QuranAudioService.instance.activeAyahNotifier,
            builder: (context, activeAyah, _) {
              if (!isPlaying && activeAyah == null) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardDarkElevated,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.accentGold,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.push('/quran-listen', extra: {
                              'surahNumber': _currentSurah.surahNumber,
                              'surahName': _currentSurahName,
                              'versesCount': _currentSurah.verses.length,
                              'initialAyah': activeAyah ?? 1,
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تلاوة ${QuranAudioService.instance.selectedReciter.name}',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: AppColors.accentGold,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'آية ${activeAyah != null ? QuranMetadata.toArabicDigits(activeAyah) : '١'} · اضغط لفتح المشغل',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: AppColors.textMuted,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          color: AppColors.sageGreen,
                          size: 30.r,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            QuranAudioService.instance.pause();
                          } else {
                            QuranAudioService.instance.resume();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 20.r,
                        ),
                        onPressed: () => QuranAudioService.instance.stop(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
