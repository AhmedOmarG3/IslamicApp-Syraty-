import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:siraty/Cubits/AzanCubit/azan_cubit.dart';
import 'package:siraty/Cubits/AzkarCubit/azkar_cubit.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit.dart';

import 'package:siraty/Presentation/Views/Splash_view.dart';
import 'package:siraty/Presentation/Views/azan_view.dart';
import 'package:siraty/Presentation/Views/azkar_view.dart';
import 'package:siraty/Presentation/Views/home_view.dart';
import 'package:siraty/Presentation/Views/quran_view.dart';
import 'package:siraty/Presentation/Views/sebha_view.dart';

void main() {
  runApp(
    const SiratyApp(),
  );
}

class SiratyApp extends StatelessWidget {
  const SiratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => QuranCubit()..loadQuran()),
        BlocProvider(create: (_) => AzkarCubit()..loadAzkar()),
        BlocProvider(create: (_) => AzanCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Amiri'),
        routes: {
          SplashView.routeName: (context) => const SplashView(),
          HomeView.routeName: (context) => const HomeView(),
          QuranView.routeName: (context) => const QuranView(),
          SebhaView.routeName: (context) => const SebhaView(),
          AzkarView.routeName: (context) => const AzkarView(),
          AzanView.routeName: (context) => const AzanView(),
        },
        initialRoute: SplashView.routeName,
      ),
    );
  }
}
