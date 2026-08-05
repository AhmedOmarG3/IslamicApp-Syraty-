import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/presentation/widgets/custom_zekr_categories_row.dart';

class AzkarViewBody extends StatelessWidget {
  const AzkarViewBody({
    super.key,
    required this.filteredAzkar,
  });

  final List<AzkarModel> filteredAzkar;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredAzkar.length,
      itemBuilder: (context, index) => CustomZekrCategoriesRow(
        name: filteredAzkar[index].category,
        onTap: () {
          context.push('/zekr-details', extra: filteredAzkar[index]);
        },
      ),
    );
  }
}
