import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/core/widgets/custom_search_bar.dart';
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
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.toLowerCase();
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
    return Scaffold(
      appBar: CustomSearchAppBar(
        title: 'القرآن الكريم',
        hintText: 'ابحث عن السورة',
        searchController: searchController,
        isSearching: isSearching,
        onSearchPressed: () {
          setState(() {
            isSearching = true;
          });
        },
        onClosePressed: () {
          setState(() {
            searchController.clear();
            isSearching = false;
          });
        },
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuranError) {
            return Center(child: Text(state.message));
          } else if (state is QuranLoaded) {
            final surahs = state.surahs;
            final filteredSurahs = surahs.where((surah) {
              final name =
                  surah.getSurahName()[surah.surahNumber - 1].toLowerCase();
              return name.contains(searchText);
            }).toList();

            return QuranBody(filteredSurahs: filteredSurahs);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
