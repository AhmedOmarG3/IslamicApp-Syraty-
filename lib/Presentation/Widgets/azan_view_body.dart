import 'package:flutter/material.dart';
import 'package:siraty/Data/Models/azan_model.dart';
import 'package:siraty/Presentation/helpers/convert_to12_hour_format.dart';
import 'package:siraty/constant.dart';

class AzanViewBody extends StatelessWidget {
  const AzanViewBody({
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
      itemCount: azanTimes.timesName().length,
      itemBuilder: (context, index) {
        String prayerName = azanTimes.timesName()[index];
        String prayerTime = convertTo12HourFormat(azanTimes.azanTimes[index]);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryColor,
                const Color.fromARGB(255, 34, 207, 63).withOpacity(0.5),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: Icon(
                getPayerIcon(prayerName),
                color: kPrimaryColor,
                size: 28,
              ),
            ),
            title: Text(
              prayerName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              prayerTime,
              style: const TextStyle(
                color: Colors.black,
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
