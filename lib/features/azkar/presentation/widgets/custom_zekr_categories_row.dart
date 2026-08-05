import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';

class CustomZekrCategoriesRow extends StatelessWidget {
  const CustomZekrCategoriesRow({
    super.key,
    required this.name,
    required this.onTap,
  });

  final VoidCallback onTap;
  final String name;

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
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_back_ios),
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
