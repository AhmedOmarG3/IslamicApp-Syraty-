import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit_state.dart';

import 'package:siraty/Presentation/Views/surah_view.dart';
import 'package:siraty/Presentation/Widgets/custom_button_with_icon.dart';

import 'package:siraty/constant.dart';

class LastReadContainer extends StatelessWidget {
  const LastReadContainer({super.key, this.title = 'اقرا الان'});
  final String title;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (state is QuranLoaded && state.lastReadSurahIndex != null) {
          final surah = state.surahs[state.lastReadSurahIndex!];
          final surahName = surah.getSurahName()[state.lastReadSurahIndex!];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kPrimaryColor, const Color(0xff87D1A4)]),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 10))
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/Group 35.png',
                    height: 200,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'القراءة الأخيرة',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'سورة : $surahName',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      CustomButtonWithIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahView(
                                surah: surah,
                                surahName: surahName,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 1,
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kPrimaryColor, const Color(0xff87D1A4)])),
                  child: Image.asset('assets/images/Group 35.png')),
              height: MediaQuery.of(context).size.height * 0.33,
              width: MediaQuery.of(context).size.width,
            ),
          );
        }
      },
    );
  }
}
