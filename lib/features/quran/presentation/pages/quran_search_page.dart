import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/services/quran_search_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_state.dart';

class QuranSearchPage extends StatefulWidget {
  const QuranSearchPage({super.key});

  @override
  State<QuranSearchPage> createState() => _QuranSearchPageState();
}

class _QuranSearchPageState extends State<QuranSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<QuranSearchResult> _results = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    QuranSearchService.instance.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = q;
    });

    final res = await QuranSearchService.instance.search(q);
    if (mounted) {
      setState(() {
        _results = res;
        _isSearching = false;
      });
    }
  }

  Future<void> _navigateToVerse(QuranSearchResult result) async {
    final cubit = context.read<QuranCubit>();
    SurahModel? targetSurah;
    if (cubit.state is QuranLoaded) {
      final surahs = (cubit.state as QuranLoaded).surahs;
      final targetIndex = result.surahNumber - 1;
      if (targetIndex >= 0 && targetIndex < surahs.length) {
        targetSurah = surahs[targetIndex];
      }
    }

    targetSurah ??= await LastReadService.loadSurah(result.surahNumber);

    if (mounted && targetSurah != null) {
      context.push('/surah-details', extra: {
        'surah': targetSurah,
        'surahName': result.surahName,
        'targetAyah': result.ayahNumber,
      });
    }
  }

  /// Highlight search query occurrences within the verse text
  WidgetSpan _buildHighlightTextSpan(String text, String query) {
    final range = QuranSearchService.findMatchRange(text, query);

    if (range == null || range.isCollapsed || query.trim().isEmpty) {
      return WidgetSpan(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15.sp,
            color: AppColors.textWhite,
            height: 1.9,
          ),
        ),
      );
    }

    final start = range.start.clamp(0, text.length);
    final end = range.end.clamp(0, text.length);

    return WidgetSpan(
      child: Text.rich(
        TextSpan(
          children: [
            if (start > 0)
              TextSpan(
                text: text.substring(0, start),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15.sp,
                  color: AppColors.textWhite,
                  height: 1.9,
                ),
              ),
            TextSpan(
              text: text.substring(start, end),
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16.sp,
                color: AppColors.accentGold,
                fontWeight: FontWeight.bold,
                backgroundColor: AppColors.accentGold.withValues(alpha: 0.28),
                height: 1.9,
              ),
            ),
            if (end < text.length)
              TextSpan(
                text: text.substring(end),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15.sp,
                  color: AppColors.textWhite,
                  height: 1.9,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: const AppHeaderBar(
          title: 'البحث في القرآن الكريم',
          subtitle: 'بحث فوري في الآيات والسور (أوفلاين)',
          showBackButton: true,
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Text Field Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.cardDarkElevated,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.35),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  textDirection: TextDirection.rtl,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16.sp,
                    color: AppColors.textWhite,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search_rounded,
                        color: AppColors.accentGold, size: 22.r),
                    hintText:
                        'ابحث عن آية أو كلمة (مثال: الكوثر، يسر، رحمة)...',
                    hintStyle: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14.sp,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.textMuted),
                            onPressed: () {
                              _controller.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _performSearch,
                ),
              ),
              SizedBox(height: 12.h),

              // Results Count Bar
              if (_currentQuery.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Icon(Icons.format_list_bulleted_rounded,
                          size: 14.r, color: AppColors.accentGold),
                      SizedBox(width: 6.w),
                      Text(
                        _isSearching
                            ? 'جارٍ البحث...'
                            : 'تم العثور على ${QuranMetadata.toArabicDigits(_results.length)} آية',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 8.h),

              // Results List
              Expanded(
                child: _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGold,
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentQuery.isEmpty
                                      ? Icons.manage_search_rounded
                                      : Icons.search_off_rounded,
                                  size: 48.r,
                                  color: AppColors.textMuted
                                      .withValues(alpha: 0.6),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  _currentQuery.isEmpty
                                      ? 'اكتب أي كلمة أو آية للبحث عنها فورياً'
                                      : 'لم يتم العثور على آيات تطابق «$_currentQuery»',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 14.sp,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final res = _results[index];
                              final arabicAyah =
                                  QuranMetadata.toArabicDigits(res.ayahNumber);

                              return GestureDetector(
                                onTap: () => _navigateToVerse(res),
                                child: Container(
                                  padding: EdgeInsets.all(14.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Top metadata line
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  color: AppColors.sageGreen
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                  border: Border.all(
                                                    color: AppColors.sageGreen,
                                                  ),
                                                ),
                                                child: Text(
                                                  'سورة ${res.surahName}',
                                                  style: TextStyle(
                                                    fontFamily: 'Amiri',
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.sageGreen,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'آية $arabicAyah · ${res.isMakki ? 'مكية' : 'مدنية'}',
                                                style: TextStyle(
                                                  fontFamily: 'Amiri',
                                                  fontSize: 12.sp,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'الانتقال للآية',
                                                style: TextStyle(
                                                  fontFamily: 'Amiri',
                                                  fontSize: 11.sp,
                                                  color: AppColors.accentGold,
                                                ),
                                              ),
                                              SizedBox(width: 4.w),
                                              Icon(Icons.arrow_back_ios_rounded,
                                                  size: 10.r,
                                                  color: AppColors.accentGold),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),

                                      // Highlighted Ayah Text
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            _buildHighlightTextSpan(
                                                res.verseText, res.searchQuery),
                                          ],
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
