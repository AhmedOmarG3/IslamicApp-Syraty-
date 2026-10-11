import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/presentation/widgets/custom_zekr_row.dart';

class ZekrPage extends StatelessWidget {
  final AzkarModel zekr;

  const ZekrPage({
    super.key,
    required this.zekr,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBackground : AppColors.bgLight,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          zekr.category,
          style: TextStyle(
            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: zekr.zekrItems.length,
        itemBuilder: (context, index) {
          final item = zekr.zekrItems[index];
          return CustomZekrRow(
            count: item.count,
            number: index + 1,
            name: item.text,
            onTap: () {},
          );
        },
      ),
    );
  }
}
