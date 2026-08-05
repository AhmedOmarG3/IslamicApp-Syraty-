import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';

class CustomRow extends StatelessWidget {
  const CustomRow({
    super.key,
    required this.number,
    required this.name,
    this.numberOfVerses = '',
    required this.onTap,
  });

  final VoidCallback onTap;
  final int number;
  final String name;
  final dynamic numberOfVerses;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  'عدد الآيات: $numberOfVerses',
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
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
