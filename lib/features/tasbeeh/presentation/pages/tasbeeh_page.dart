import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  int counter = 0;
  int index = 0;

  final List<String> tasbeeh = const [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'استغفر الله',
    'اللهم صل على محمد وآل محمد',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'سبحة',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
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
                  color: AppColors.darkTeal,
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  tasbeeh[index],
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
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
                        AppAssets.sebhaBackground,
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
                            color: AppColors.white,
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
                            color: AppColors.white,
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
                            color: AppColors.white,
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
