import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomRow extends StatelessWidget {
  const CustomRow(
      {super.key,
      required this.number,
      required this.name,
      this.numberOfVerses = '',
      required this.onTap});
  final void Function() onTap;
  final int number;
  final String name;
  final numberOfVerses;
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
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xff87D1A4),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                ),
                Text(
                  'عدد الآيات: $numberOfVerses',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor),
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
