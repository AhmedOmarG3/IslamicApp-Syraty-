import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomZekrCategoresRow extends StatelessWidget {
  const CustomZekrCategoresRow(
      {super.key, required this.name, required this.onTap});
  final void Function() onTap;

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
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_back_ios),
                ),
                Expanded(
                  child: Text(
                    textDirection: TextDirection.rtl,
                    softWrap: true,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    name,
                    style: TextStyle(
                        height: 2.5,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
