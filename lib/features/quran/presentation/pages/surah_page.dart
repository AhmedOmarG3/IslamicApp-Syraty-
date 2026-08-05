import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/presentation/widgets/custom_ayah_row.dart';
import 'package:siraty/features/quran/presentation/widgets/custom_surah_container.dart';

class SurahPage extends StatelessWidget {
  final SurahModel surah;
  final String surahName;

  const SurahPage({
    super.key,
    required this.surah,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          surahName,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CustomSurahContainer(
              surahName: surahName,
              surahModel: surah,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final verse = surah.verses[index];
                return CustomAyahRow(
                  number: index + 1,
                  name: verse.text,
                  onTap: () {},
                );
              },
              childCount: surah.verses.length,
            ),
          ),
        ],
      ),
    );
  }
}
