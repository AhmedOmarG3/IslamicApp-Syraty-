import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/app_skeleton.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_state.dart';
import 'package:siraty/features/quran/presentation/widgets/quran_body.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(
        title: 'القرآن الكريم',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Search Bar Row with Full Quran Search Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDarkElevated
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle
                            : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      controller: searchController,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textDarkPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سورة...',
                        hintStyle: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textDimmed
                              : AppColors.textDarkMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? AppColors.sageGreen
                              : AppColors.sageGreenDark,
                          size: 20.r,
                        ),
                        suffixIcon: searchText.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark
                                      ? AppColors.textMuted
                                      : AppColors.textDarkMuted,
                                  size: 18.r,
                                ),
                                onPressed: () => searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () => context.push('/quran-search'),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDarkElevated
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderGold
                            : AppColors.accentGold,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            color: AppColors.accentGold, size: 18.r),
                        SizedBox(width: 6.w),
                        Text(
                          'بحث الآيات',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Quran List Content
          Expanded(
            child: BlocBuilder<QuranCubit, QuranState>(
              builder: (context, state) {
                if (state is QuranLoading) {
                  return const SurahListSkeleton();
                } else if (state is QuranError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.errorRed),
                    ),
                  );
                } else if (state is QuranLoaded) {
                  final surahs = state.surahs;
                  final filteredSurahs = surahs.where((surah) {
                    final name = surah
                        .getSurahName()[surah.surahNumber - 1]
                        .toLowerCase();
                    return name.contains(searchText);
                  }).toList();

                  return QuranBody(filteredSurahs: filteredSurahs);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
