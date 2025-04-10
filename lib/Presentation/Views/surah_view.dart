import 'package:flutter/material.dart';
import 'package:siraty/Data/Models/surah_model.dart';
import 'package:siraty/Presentation/Widgets/custom_ayah_row.dart';
import 'package:siraty/Presentation/Widgets/custom_surah_container.dart';
import 'package:siraty/constant.dart';

class SurahView extends StatelessWidget {
  final SurahModel surah;
  final String surahName;

  const SurahView({super.key, required this.surah, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          surahName,
          style: const TextStyle(
              color: kPrimaryColor, fontSize: 25, fontWeight: FontWeight.bold),
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
                    number: index + 1, name: verse.text, onTap: () {});
              },
              childCount: surah.verses.length,
            ),
          ),
        ],
      ),
    );
  }
}
