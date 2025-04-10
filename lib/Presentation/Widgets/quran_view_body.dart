import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit.dart';
import 'package:siraty/Data/Models/surah_model.dart';
import 'package:siraty/Presentation/Views/surah_view.dart';
import 'package:siraty/Presentation/Widgets/custom_row.dart';

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
            context.read<QuranCubit>().updateLastRead(index);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahView(
                  surah: surah,
                  surahName: name,
                ),
              ),
            );
          },
          numberOfVerses: surah.verses.length,
          name: name,
          number: surah.surahNumber,
        );
      },
    );
  }
}
