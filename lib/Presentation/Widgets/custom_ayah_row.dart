import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomAyahRow extends StatelessWidget {
  const CustomAyahRow(
      {super.key,
      required this.number,
      required this.name,
      required this.onTap});
  final void Function() onTap;
  final int number;
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
              children: [
                Container(
                  height: 50,
                  width: 70,
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/ayah_number.png')),
                  ),
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
