// Date utilities for relative times and full formats
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String timeAgo(DateTime date) {
    try {
      return timeago.format(date.toLocal(), allowFromNow: true);
    } catch (_) {
      return DateFormat.yMd().add_jm().format(date.toLocal());
    }
  }

  static String fullDate(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date.toLocal());
  }
}
