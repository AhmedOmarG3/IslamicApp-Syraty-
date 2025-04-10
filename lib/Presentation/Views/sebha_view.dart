import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class SebhaView extends StatefulWidget {
  const SebhaView({super.key});
  static const String routeName = '/sebha_view';

  @override
  State<SebhaView> createState() => _SebhaViewState();
}

class _SebhaViewState extends State<SebhaView> {
  int counter = 0;
  int index = 0;

  List<String> tasbeeh = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'استغفر الله',
    'اللهم صل على محمد وآل محمد'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'سبحة',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 3, 62, 53),
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  tasbeeh[index],
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageWidth = constraints.maxWidth;
                  final imageHeight = constraints.maxHeight;

                  return Stack(
                    children: [
                      Image.asset(
                        'assets/images/sebha2.png',
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                      Align(
                        alignment: const Alignment(0.02, -0.35),
                        child: Text(
                          counter.toString(),
                          style: const TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-.17, 0.12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              counter = 0;
                            });
                          },
                          child: const Icon(
                            Icons.replay,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.19, 0.12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              counter++;
                            });
                            if (counter == 34) {
                              counter = 0;
                              index++;
                              if (index == tasbeeh.length) {
                                index = 0;
                              }
                            }
                          },
                          child: const Icon(
                            Icons.add,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
