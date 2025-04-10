import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/Cubits/AzkarCubit/azkar_cubit.dart';
import 'package:siraty/Presentation/Widgets/azkar_view_body.dart';
import 'package:siraty/Presentation/Widgets/custom_search_appBar.dart';

class AzkarView extends StatefulWidget {
  const AzkarView({super.key});
  static String routeName = 'AzkarView';
  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
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
      backgroundColor: Colors.white,
      appBar: CustomSearchAppbar(
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
        title: 'الاذكار',
        isSearching: isSearching,
        searchController: searchController,
        hintText: 'ابحث عن ذكر...',
      ),
      body: BlocBuilder<AzkarCubit, AzkarCubitState>(
        builder: (context, state) {
          if (state is AzkarLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AzkarLoadedState) {
            final azkar = state.azkarList;
            final filteredAzkar = azkar.where((zekr) {
              final name = zekr.category!.toLowerCase();
              return name.contains(searchText);
            }).toList();

            return AzkarViewBody(
              filteredAzkar: filteredAzkar,
            );
          } else if (state is AzkarFailureState) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const Center(
              child: Text('Something went wrong!'),
            );
          }
        },
      ),
    );
  }
}
