import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../../data/models/prayer_snapshot_model.dart';
import '../entities/prayer_time.dart';

class PrayerWidgetService {
  static const String androidWidgetName = 'PrayerWidgetProvider';

  static String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  static String _formatTime(DateTime time) {
    final formatted = DateFormat('hh:mm').format(time);
    return _toArabicDigits(formatted);
  }

  static Future<void> updateWidget({required PrayerSnapshotModel snapshot}) async {
    final now = DateTime.now();
    final nextPrayer = snapshot.today.nextPrayer(now, includeSunrise: false) ??
        snapshot.tomorrow.getTime(PrayerType.fajr);

    final fajr = snapshot.today.getTime(PrayerType.fajr);
    final dhuhr = snapshot.today.getTime(PrayerType.dhuhr);
    final asr = snapshot.today.getTime(PrayerType.asr);
    final maghrib = snapshot.today.getTime(PrayerType.maghrib);
    final isha = snapshot.today.getTime(PrayerType.isha);

    String remainingText = '';
    if (nextPrayer != null) {
      final diff = nextPrayer.time.difference(now);
      if (diff.isNegative || diff.inSeconds <= 0) {
        remainingText = '• حان وقت الصلاة';
      } else {
        final totalSeconds = diff.inSeconds.abs();
        final hours = totalSeconds ~/ 3600;
        final mins = (totalSeconds % 3600) ~/ 60;
        final secs = totalSeconds % 60;
        final hStr = hours.toString().padLeft(2, '0');
        final mStr = mins.toString().padLeft(2, '0');
        final sStr = secs.toString().padLeft(2, '0');
        final en = hours > 0 ? '$hStr:$mStr:$sStr' : '$mStr:$sStr';
        remainingText = '• متبقي ${_toArabicDigits(en)}';
      }
    }

    await HomeWidget.saveWidgetData<String>(
      'prayer_city',
      snapshot.location.cityName,
    );
    await HomeWidget.saveWidgetData<String>(
      'prayer_next_name',
      nextPrayer != null ? 'الصلاة القادمة: ${nextPrayer.arabicName}' : 'مواقيت الصلاة',
    );
    await HomeWidget.saveWidgetData<String>(
      'prayer_next_time',
      nextPrayer != null ? _formatTime(nextPrayer.time) : '--:--',
    );
    await HomeWidget.saveWidgetData<String>(
      'prayer_next_key',
      nextPrayer?.key.name ?? '',
    );
    await HomeWidget.saveWidgetData<String>(
      'prayer_next_remaining',
      remainingText,
    );

    if (fajr != null) {
      await HomeWidget.saveWidgetData<String>('prayer_fajr_time', _formatTime(fajr.time));
      await HomeWidget.saveWidgetData<int>('prayer_fajr_epoch', fajr.time.millisecondsSinceEpoch);
    }
    if (dhuhr != null) {
      await HomeWidget.saveWidgetData<String>('prayer_dhuhr_time', _formatTime(dhuhr.time));
      await HomeWidget.saveWidgetData<int>('prayer_dhuhr_epoch', dhuhr.time.millisecondsSinceEpoch);
    }
    if (asr != null) {
      await HomeWidget.saveWidgetData<String>('prayer_asr_time', _formatTime(asr.time));
      await HomeWidget.saveWidgetData<int>('prayer_asr_epoch', asr.time.millisecondsSinceEpoch);
    }
    if (maghrib != null) {
      await HomeWidget.saveWidgetData<String>('prayer_maghrib_time', _formatTime(maghrib.time));
      await HomeWidget.saveWidgetData<int>('prayer_maghrib_epoch', maghrib.time.millisecondsSinceEpoch);
    }
    if (isha != null) {
      await HomeWidget.saveWidgetData<String>('prayer_isha_time', _formatTime(isha.time));
      await HomeWidget.saveWidgetData<int>('prayer_isha_epoch', isha.time.millisecondsSinceEpoch);
    }

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
    );
  }
}
