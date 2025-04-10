import 'package:flutter/material.dart';
import 'package:siraty/Data/Models/azkar_model.dart';
import 'package:siraty/Presentation/Views/zekr_view.dart';
import 'package:siraty/Presentation/Widgets/custom_zekr_categores_row.dart';

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
      itemBuilder: (context, index) => CustomZekrCategoresRow(
        name: filteredAzkar[index].category!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZekrView(
                Zekr: filteredAzkar[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
