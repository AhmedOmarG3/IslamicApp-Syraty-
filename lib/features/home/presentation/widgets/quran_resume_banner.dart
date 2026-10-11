import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_card.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_state.dart';

class QuranResumeBanner extends StatelessWidget {
  const QuranResumeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      buildWhen: (previous, current) => current is QuranLoaded,
      builder: (context, state) {
        if (state is! QuranLoaded || state.lastReadSurahIndex == null) {
          return const SizedBox.shrink();
        }

        final index = state.lastReadSurahIndex!;
        if (index < 0 || index >= state.surahs.length) {
          return const SizedBox.shrink();
        }

        final surah = state.surahs[index];
        final name = surah.surahName;

        return AppCard(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: EdgeInsets.all(16.w),
          backgroundColor: AppColors.accentMint,
          onTap: () {
            final lastRead = LastReadService.lastReadNotifier.value;
            final targetAyah = (lastRead != null && lastRead.surahNumber == surah.surahNumber)
                ? lastRead.ayahNumber
                : null;
            context.push(
              '/surah-details',
              extra: {
                'surah': surah,
                'surahName': name,
                if (targetAyah != null) 'targetAyah': targetAyah,
              },
            );
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('متابعة القراءة', style: AppTextStyles.caption),
                    AppSpacing.verticalXs,
                    Text(
                      'سورة $name',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        );
      },
    );
  }
}
