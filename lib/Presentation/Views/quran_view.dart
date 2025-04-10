import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit_state.dart';
import 'package:siraty/Presentation/Widgets/custom_search_appBar.dart';
import 'package:siraty/Presentation/Widgets/quran_view_body.dart';


class QuranView extends StatefulWidget {
  const QuranView({super.key});
static const String routeName = '/quran_view';
  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> {
  TextEditingController searchController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchAppbar(
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
