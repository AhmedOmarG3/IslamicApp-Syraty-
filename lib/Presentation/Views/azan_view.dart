import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/Cubits/AzanCubit/azan_cubit.dart';
import 'package:siraty/Presentation/Widgets/azan_view_body.dart';
import 'package:siraty/constant.dart';

class AzanView extends StatefulWidget {
  const AzanView({super.key});
  static String routeName = 'AzanView';
  @override
  State<AzanView> createState() => _AzanViewState();
}

class _AzanViewState extends State<AzanView> {
  String? city;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('الصلوات',
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold)),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(10)),
                labelText: 'أدخل المدينة',
                labelStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                    borderSide: const BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (value) {
                city = value;
                context.read<AzanCubit>().loadAzan(city: city!, country: '');
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: BlocBuilder<AzanCubit, AzanState>(builder: (context, state) {
              if (state is AzanLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is AzanFailureState) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: kPrimaryColor,
                        size: 60,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'لم نتمكن من جلب مواعيد الصلاة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else if (state is AzanLoadedState) {
                final azanTimes = state.azanList;

                return AzanViewBody(azanTimes: azanTimes);
              } else {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mosque,
                          size: 100, color: kPrimaryColor.withOpacity(0.7)),
                      const SizedBox(height: 20),
                      const Text(
                        'أهلاً بيك في تطبيق سيرتى!\nمن فضلك أدخل اسم المدينة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        children: ['القدس', 'مكة', 'القاهرة']
                            .map((cityName) => ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<AzanCubit>()
                                        .loadAzan(city: cityName, country: '');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        kPrimaryColor.withOpacity(0.7),
                                  ),
                                  child: Text(
                                    cityName,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                );
              }
            }),
          ),
        ]),
      ),
    );
  }
}
