import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomZekrRow extends StatelessWidget {
  const CustomZekrRow(
      {super.key,
      required this.number,
      required this.name,
      required this.onTap,
       this.count});
  final void Function() onTap;
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
                    Text('عدد التكرار\n    $count',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    
                  ],
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
