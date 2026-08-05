import 'package:intl/intl.dart';

abstract class DateFormatter {
  static String convertTo12HourFormat(String time24) {
    try {
      final time = DateFormat("HH:mm").parse(time24);
      return DateFormat("h:mm a").format(time);
    } catch (_) {
      return time24;
    }
  }
}
