import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/app_constants.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/features/home/presentation/widgets/home_body.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.appBarTitle.copyWith(
            fontSize: 30.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: HomeBody(),
      ),
    );
  }
}
