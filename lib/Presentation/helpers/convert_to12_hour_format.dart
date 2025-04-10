import 'package:intl/intl.dart';

String convertTo12HourFormat(String time24) {
  final time = DateFormat("HH:mm").parse(time24);  
  return DateFormat("h:mm a").format(time); 
}
