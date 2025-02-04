import 'package:intl/intl.dart';

String formatDateTime(String dateTimeStr) {
  try {
    final dateTime = DateTime.parse(dateTimeStr);
    // Format the date and time as you prefer.
    // For example: Feb 4, 2025, 1:47 AM
    return DateFormat.yMMMd().add_jm().format(dateTime);
  } catch (e) {
    return dateTimeStr;
  }
}
