import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/utils/date_formatter.dart';
import 'package:siraty/features/prayer/data/models/azan_model.dart';

class PrayerBody extends StatelessWidget {
  const PrayerBody({
    super.key,
    required this.azanTimes,
  });

  final AzanModel azanTimes;

  IconData getPayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Icons.wb_twilight;
      case 'الشروق':
        return Icons.wb_sunny;
      case 'الظهر':
        return Icons.sunny;
      case 'العصر':
        return Icons.brightness_5;
      case 'المغرب':
        return Icons.nightlight;
      case 'العشاء':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: azanTimes.timesName.length,
      itemBuilder: (context, index) {
        String prayerName = azanTimes.timesName[index];
        String prayerTime =
            DateFormatter.convertTo12HourFormat(azanTimes.azanTimes[index]);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen,
                const Color.fromARGB(255, 34, 207, 63).withValues(alpha: 0.5),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: AppColors.white,
              radius: 25,
              child: Icon(
                getPayerIcon(prayerName),
                color: AppColors.primaryGreen,
                size: 28,
              ),
            ),
            title: Text(
              prayerName,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              prayerTime,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
