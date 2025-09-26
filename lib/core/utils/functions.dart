import 'package:intl/intl.dart';

String formatDateTime(DateTime date) {
  final day = date.day;
  final suffix = getDaySuffix(day);

  final formattedDate = DateFormat("MMMM, yyyy hh:mma").format(date);
  // Insert the day with suffix in front
  return "$day$suffix $formattedDate";
}

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return "th";
  }
  switch (day % 10) {
    case 1:
      return "st";
    case 2:
      return "nd";
    case 3:
      return "rd";
    default:
      return "th";
  }
}