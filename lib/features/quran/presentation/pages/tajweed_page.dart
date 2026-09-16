import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../domain/entities/tajweed_rule.dart';
import '../../domain/services/tajweed_service.dart';

class TajweedPage extends StatefulWidget {
  const TajweedPage({super.key});

  @override
  State<TajweedPage> createState() => _TajweedPageState();
}

class _TajweedPageState extends State<TajweedPage> {
  List<TajweedCategory> _allCategories = [];
  List<TajweedCategory> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategoryId = 'all';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final categories = await TajweedService.loadTajweedCategories();
    if (mounted) {
      setState(() {
        _allCategories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final query = _searchQuery.trim().toLowerCase();
    setState(() {
      _filteredCategories = _allCategories.where((cat) {
        if (_selectedCategoryId != 'all' && cat.id != _selectedCategoryId) {
          return false;
        }
        if (query.isEmpty) return true;

        final inTitle = cat.title.toLowerCase().contains(query);
        final inDesc = cat.description.toLowerCase().contains(query);
        final inRules = cat.rules.any((r) =>
            r.name.toLowerCase().contains(query) ||
            r.definition.toLowerCase().contains(query) ||
            r.letters.toLowerCase().contains(query) ||
            r.examples.any((e) =>
                e.word.toLowerCase().contains(query) ||
                e.explanation.toLowerCase().contains(query)));

        return inTitle || inDesc || inRules;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(
        title: 'أحكام التجويد والوقف',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Search Box
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _searchQuery = val;
                        _filter();
                      },
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14.sp,
                        color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن حكم، حرف، أو علامة وقف...',
                        hintStyle: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13.sp,
                          color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentGold),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _filter();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      ),
                    ),
                  ),
                ),

                // 2. Category Filter Chips
                SizedBox(
                  height: 42.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      _buildChip(id: 'all', label: 'الكل', isDark: isDark),
                      ..._allCategories.map((c) => _buildChip(id: c.id, label: c.title, isDark: isDark)),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // 3. Category & Rules List
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد نتائج مطابقة لبحثك',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 15.sp,
                              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: _filteredCategories.length,
                          separatorBuilder: (_, __) => SizedBox(height: 14.h),
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            return _buildCategoryCard(category, isDark);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildChip({
    required String id,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategoryId = id);
        _filter();
      },
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold
              : (isDark ? AppColors.cardDarkElevated : AppColors.cardLight),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 12.5.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? const Color(0xFF141C18)
                : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(TajweedCategory category, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _selectedCategoryId != 'all' || _searchQuery.isNotEmpty,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.accentGold,
              size: 20,
            ),
          ),
          title: Text(
            category.title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
            ),
          ),
          subtitle: Text(
            category.description,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12.sp,
              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
            ),
          ),
          children: category.rules.map((rule) => _buildRuleItem(rule, isDark)).toList(),
        ),
      ),
    );
  }

  Widget _buildRuleItem(TajweedRule rule, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.accentGold, width: 0.8),
                ),
                child: Text(
                  rule.name,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : const Color(0xFFF2ECE1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    rule.letters,
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 13.sp,
                      color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            rule.definition,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13.5.sp,
              color: isDark ? AppColors.textMuted : AppColors.textDarkSecondary,
              height: 1.5,
            ),
          ),
          if (rule.types.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...rule.types.map((type) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : const Color(0xFFFBF6EC),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.25), width: 0.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ${type.typeName} (${type.typeLetters})',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                      if (type.examples.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: type.examples.map((ex) {
                            return Text(
                              '﴿ ${ex.word} ﴾ ${ex.explanation}',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 12.sp,
                                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
          if (rule.examples.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : const Color(0xFFFBF6EC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أمثلة قرآنية:',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...rule.examples.map((ex) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDarkElevated
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.borderGold.withValues(alpha: 0.25),
                            width: 0.6,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '﴿ ${ex.word} ﴾',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: 14.sp,
                                height: 1.6,
                                color: isDark ? AppColors.textWhite : const Color(0xFF141C18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (ex.explanation.isNotEmpty) ...[
                              SizedBox(height: 3.h),
                              Text(
                                '• ${ex.explanation}',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 11.5.sp,
                                  color: isDark ? AppColors.accentGoldLight : AppColors.sageGreenDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
