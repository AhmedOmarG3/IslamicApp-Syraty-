import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomButtonWithIcon extends StatelessWidget {
  const CustomButtonWithIcon({super.key, this.onPressed});
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffFAF6EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onPressed,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              size: 25,
              textDirection: TextDirection.ltr,
              Icons.arrow_back,
              color: kPrimaryColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '  تابع ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
