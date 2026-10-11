import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/services/favorites_service.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/app_skeleton.dart';
import 'package:siraty/core/widgets/islamic_share_card_dialog.dart';
import '../../data/models/hadith_model.dart';
import '../../data/services/hadith_service.dart';
import '../widgets/hadith_card.dart';
import '../widgets/hadith_chapter_tile.dart';
import '../widgets/hadith_search_bar.dart';

enum HadithViewMode {
  chapters, // المستوى الأول: قائمة الأبواب (جذر الصفحة)
  hadiths, // المستوى الثاني: أحاديث الباب المختار
}

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  HadithViewMode _viewMode = HadithViewMode.chapters;

  // The single hadith book bundled with the app.
  static const Map<String, String> _activeCollection = {
    'key': 'selected',
    'label': 'الأحاديث النبوية الشريفة',
    'subtitle': 'الأربعون النووية ومختارات السنة',
  };

  HadithChapterInfo? _selectedChapter;

  List<HadithModel> _currentBookHadiths = [];
  List<HadithChapterInfo> _currentBookChapters = [];
  List<HadithModel> _currentChapterHadiths = [];

  // Search states
  String _searchQuery = '';
  List<HadithModel> _searchResults = [];

  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.getFavorites();
    _loadHadiths();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Loads the bundled hadith collection and derives its chapter list.
  Future<void> _loadHadiths() async {
    setState(() => _isLoading = true);

    final data = await HadithService.loadBook(_activeCollection['key']!);
    final chapters = HadithService.getChaptersWithCounts(data);

    if (!mounted) return;
    setState(() {
      _currentBookHadiths = data;
      _currentBookChapters = chapters;
      _isLoading = false;
    });
  }

  void _selectChapter(HadithChapterInfo chapter) {
    final chapterName = chapter.name.trim();
    final hadiths = _currentBookHadiths.where((h) {
      final ch = h.chapter.trim().isNotEmpty ? h.chapter.trim() : h.category.trim();
      return ch == chapterName;
    }).toList();

    setState(() {
      _selectedChapter = chapter;
      _currentChapterHadiths = hadiths;
      _viewMode = HadithViewMode.hadiths;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _onGlobalSearch(String query) async {
    final trimmed = query.trim();
    setState(() {
      _searchQuery = trimmed;
    });

    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    if (_currentBookHadiths.isEmpty) {
      final data = await HadithService.loadBook(_activeCollection['key']!);
      _currentBookHadiths = data;
    }

    final results = HadithService.searchHadiths(_currentBookHadiths, trimmed);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _clearGlobalSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
    });
  }

  void _toggleFavorite(HadithModel hadith) async {
    final item = FavoriteItem(
      id: '${hadith.book}_${hadith.id}',
      type: FavoriteType.hadith,
      title: hadith.title.isNotEmpty ? hadith.title : 'حديث شريف',
      subtitle: hadith.chapter.isNotEmpty ? hadith.chapter : hadith.book,
      content: hadith.arabic,
    );

    final isFav = FavoritesService.instance.items.any(
      (e) => (e.id == item.id || e.id == hadith.id.toString()) && e.type == FavoriteType.hadith,
    );

    await FavoritesService.instance.toggleFavorite(item);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFav ? 'تمت إزالة الحديث من المفضلة' : 'تمت إضافة الحديث إلى المفضلة',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: isFav ? AppColors.textDarkMuted : AppColors.sageGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _copyHadith(HadithModel hadith) {
    final buffer = StringBuffer();
    if (hadith.title.isNotEmpty) buffer.writeln('【 ${hadith.title} 】\n');
    if (hadith.narrator.isNotEmpty) buffer.writeln('عن ${hadith.narrator}:');
    buffer.writeln(hadith.arabic);
    buffer.writeln('\n المصدر: ${hadith.book}');
    if (hadith.chapter.isNotEmpty) buffer.writeln(' الباب: ${hadith.chapter}');
    if (hadith.explanation.isNotEmpty) {
      buffer.writeln('\n الشرح: ${hadith.explanation}');
    }
    buffer.writeln('\nمن تطبيق سِيرتي');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ نص الحديث الشريف',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: AppColors.sageGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareHadithCard(HadithModel hadith) {
    IslamicShareCardDialog.show(
      context,
      type: ShareCardType.hadith,
      contentText: hadith.arabic,
      title: hadith.title,
      subtitle: hadith.narrator.isNotEmpty ? hadith.narrator : hadith.chapter,
      source: hadith.chapter.isNotEmpty ? '${hadith.book} • ${hadith.chapter}' : hadith.book,
      extraNote: hadith.explanation.isNotEmpty ? hadith.explanation : null,
    );
  }

  bool _handleBackPress() {
    if (_searchQuery.isNotEmpty) {
      _clearGlobalSearch();
      return false;
    }
    if (_viewMode == HadithViewMode.hadiths) {
      setState(() => _viewMode = HadithViewMode.chapters);
      return false;
    }
    // The chapter list is the root view, so back leaves the page.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _viewMode == HadithViewMode.chapters && _searchQuery.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SafeArea(
          child: _searchQuery.isNotEmpty
              ? _buildSearchResultsView(isDark)
              : _isLoading
                  ? _buildLoadingState(isDark)
                  : _buildCurrentView(isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentView(bool isDark) {
    switch (_viewMode) {
      case HadithViewMode.chapters:
        return _buildChaptersView(isDark);
      case HadithViewMode.hadiths:
        return _buildHadithsView(isDark);
    }
  }

  // ==========================================
  // المستوى الأول: قائمة الأبواب
  // ==========================================
  Widget _buildChaptersView(bool isDark) {
    return Column(
      children: [
        AppHeaderBar(
          title: _activeCollection['label']!,
          subtitle: _activeCollection['subtitle'],
          showBackButton: true,
        ),
        HadithSearchBar(
          controller: _searchController,
          hintText: 'ابحث بالكلمة أو بالمعنى في الأحاديث...',
          onSubmitted: _onGlobalSearch,
          onClear: _clearGlobalSearch,
          isDark: isDark,
          hasQuery: _searchQuery.isNotEmpty,
          withShadow: true,
        ),
        Expanded(
          child: _currentBookChapters.isEmpty
              ? _buildEmptyChaptersState(isDark)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _currentBookChapters.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final ch = _currentBookChapters[index];
                    return HadithChapterTile(
                      chapter: ch,
                      isDark: isDark,
                      onTap: () => _selectChapter(ch),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // المستوى الثاني: أحاديث الباب المختار
  // ==========================================
  Widget _buildHadithsView(bool isDark) {
    return Column(
      children: [
        AppHeaderBar(
          title: _selectedChapter?.name ?? 'أحاديث الباب',
          showBackButton: true,
          onBack: () {
            setState(() {
              _viewMode = HadithViewMode.chapters;
            });
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_outline_rounded, color: AppColors.accentGold, size: 15.r),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '${_activeCollection['label']} • ${_selectedChapter?.name ?? 'أحاديث الباب'}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _currentChapterHadiths.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _currentChapterHadiths.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final hadith = _currentChapterHadiths[index];
                    return HadithCard(
                      hadith: hadith,
                      isDark: isDark,
                      onToggleFavorite: () => _toggleFavorite(hadith),
                      onCopy: () => _copyHadith(hadith),
                      onShare: () => _shareHadithCard(hadith),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // نتائج البحث العام
  // ==========================================
  Widget _buildSearchResultsView(bool isDark) {
    return Column(
      children: [
        AppHeaderBar(
          title: 'نتائج البحث',
          showBackButton: true,
          onBack: _clearGlobalSearch,
        ),
        HadithSearchBar(
          controller: _searchController,
          hintText: 'ابحث بالكلمة أو بالمعنى في الأحاديث...',
          onSubmitted: _onGlobalSearch,
          onClear: _clearGlobalSearch,
          isDark: isDark,
          hasQuery: _searchQuery.isNotEmpty,
          withShadow: true,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 14.r, color: AppColors.accentGold),
              SizedBox(width: 6.w),
              Text(
                'نتائج البحث في ${_activeCollection['label']}',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12.sp,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final hadith = _searchResults[index];
                    return HadithCard(
                      hadith: hadith,
                      isDark: isDark,
                      onToggleFavorite: () => _toggleFavorite(hadith),
                      onCopy: () => _copyHadith(hadith),
                      onShare: () => _shareHadithCard(hadith),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        AppHeaderBar(
          title: _activeCollection['label']!,
          subtitle: _activeCollection['subtitle'],
          showBackButton: true,
        ),
        Expanded(
          child: AppShimmer(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => SkeletonBox(
                height: 70.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChaptersState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.r,
              color: AppColors.accentGold.withValues(alpha: 0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              'لا يوجد باب بهذا الاسم',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'تأكد من كتابة اسم الباب بشكل صحيح',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 52.r,
              color: AppColors.accentGold.withValues(alpha: 0.4),
            ),
            SizedBox(height: 12.h),
            Text(
              'لم يتم العثور على أحاديث مطابقة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'جرّب البحث بكلمة أو عبارة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
