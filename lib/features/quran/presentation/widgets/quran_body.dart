import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/widgets/custom_row.dart';

class QuranBody extends StatelessWidget {
  const QuranBody({
    super.key,
    required this.filteredSurahs,
  });

  final List<SurahModel> filteredSurahs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        final name = surah.getSurahName()[surah.surahNumber - 1];

        return CustomRow(
          onTap: () {
            context.read<QuranCubit>().updateLastRead(surah.surahNumber - 1);
            context.push('/surah-details', extra: {
              'surah': surah,
              'surahName': name,
            });
          },
          numberOfVerses: surah.verses.length,
          name: name,
          number: surah.surahNumber,
        );
      },
    );
  }
}
