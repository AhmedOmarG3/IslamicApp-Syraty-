import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';

class CustomZekrRow extends StatelessWidget {
  const CustomZekrRow({
    super.key,
    required this.number,
    required this.name,
    required this.onTap,
    this.count,
  });

  final VoidCallback onTap;
  final int number;
  final String name;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'عدد التكرار\n    ${count ?? 0}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Text(
                    name,
                    textDirection: TextDirection.rtl,
                    softWrap: true,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      height: 2.5,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: AppColors.grey,
              thickness: 1,
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
