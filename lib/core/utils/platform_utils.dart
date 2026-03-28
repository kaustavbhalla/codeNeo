import 'package:intl/intl.dart';

/// Platform identifiers.
enum Platform {
  leetcode('LeetCode', 'LC'),
  codeforces('Codeforces', 'CF'),
  codechef('CodeChef', 'CC');

  final String displayName;
  final String shortName;
  const Platform(this.displayName, this.shortName);
}

/// Contest phase.
enum ContestPhase {
  upcoming,
  running,
  finished,
}

/// Date/time formatting utilities.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _utcFormat = DateFormat('dd MMM | HH:mm');
  static final DateFormat _localFormat = DateFormat('dd MMM | HH:mm');
  static final DateFormat _dateOnly = DateFormat('dd MMM yyyy');
  static final DateFormat _timeOnly = DateFormat('HH:mm');

  /// Format as UTC string (e.g., "28 MAR | 20:00")
  static String formatUtc(DateTime dateTime) {
    return _utcFormat.format(dateTime.toUtc()).toUpperCase();
  }

  /// Format as local time string
  static String formatLocal(DateTime dateTime) {
    return _localFormat.format(dateTime.toLocal()).toUpperCase();
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    return _dateOnly.format(dateTime).toUpperCase();
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return _timeOnly.format(dateTime);
  }

  /// Human-readable countdown (e.g., "2d 5h 30m")
  static String countdown(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);

    if (diff.isNegative) return 'STARTED';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) return '${days}D ${hours}H ${minutes}M';
    if (hours > 0) return '${hours}H ${minutes}M';
    return '${minutes}M';
  }

  /// Duration format (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}H ${minutes}M';
    if (hours > 0) return '${hours}H';
    return '${minutes}M';
  }

  /// Relative time (e.g., "2 hours ago", "in 3 days")
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (diff.isNegative) {
      final ago = now.difference(dateTime);
      if (ago.inDays > 0) return '${ago.inDays}d ago';
      if (ago.inHours > 0) return '${ago.inHours}h ago';
      return '${ago.inMinutes}m ago';
    } else {
      if (diff.inDays > 0) return 'in ${diff.inDays}d';
      if (diff.inHours > 0) return 'in ${diff.inHours}h';
      return 'in ${diff.inMinutes}m';
    }
  }
}
