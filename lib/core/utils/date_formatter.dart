// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 365) return DateFormat('MMM d').format(date);
    return DateFormat('MMM d, y').format(date);
  }

  static String formatBookingDate(DateTime date) {
    return DateFormat('EEEE, MMM d, y').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${formatBookingDate(date)} at ${formatTime(date)}';
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('MMMM d, yyyy - hh:mm a').format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo';
    return '${(difference.inDays / 365).floor()}y';
  }
}