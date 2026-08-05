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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          zekr.category,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}
