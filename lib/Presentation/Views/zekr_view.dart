
import 'package:flutter/material.dart';
import 'package:siraty/Data/Models/azkar_model.dart';

import 'package:siraty/Presentation/Widgets/custom_zekr_row.dart';
import 'package:siraty/constant.dart';

class ZekrView extends StatelessWidget {
  final AzkarModel Zekr;
  
  const ZekrView(
      {super.key, required this.Zekr,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Zekr.category!,
          style:const TextStyle(
              color: kPrimaryColor, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: ListView.builder(
              itemCount: Zekr.zekrItems!.length,
              itemBuilder: (context, index) {
                final zekr = Zekr.zekrItems![index];
                return CustomZekrRow(count:zekr.count!, 
                    number: index + 1,
                    name: zekr.text!,
                    onTap: () {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
