import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/custom_search_bar.dart';
import 'package:siraty/features/azkar/presentation/cubit/azkar_cubit.dart';
import 'package:siraty/features/azkar/presentation/cubit/azkar_state.dart';
import 'package:siraty/features/azkar/presentation/widgets/azkar_view_body.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
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
      backgroundColor: AppColors.white,
      appBar: CustomSearchAppBar(
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
              final name = zekr.category.toLowerCase();
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
