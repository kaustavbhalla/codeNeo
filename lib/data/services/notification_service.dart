import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/contest.dart';
import '../models/notification_settings.dart';

/// Handles scheduling and managing contest notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'contest_alerts',
      'Contest Alerts',
      description: 'Notifications for upcoming competitive programming contests',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.createNotificationChannel(channel);
    
    // Request permissions for Android 13+ and exact alarms for Android 12+
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — payload contains contest URL
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Schedule all notifications for a contest based on settings.
  Future<void> scheduleContestNotifications(
    Contest contest,
    NotificationSettings settings,
  ) async {
    if (!settings.masterEnabled) return;
    if (!settings.isPlatformEnabled(contest.platform.name)) return;
    if (!contest.notificationsEnabled) return;

    // Cancel existing notifications for this contest first
    await cancelContestNotifications(contest);

    final offsets = settings.activeOffsets;

    for (final offset in offsets) {
      final notifyTime = contest.startTime.subtract(offset);

      // Don't schedule notifications in the past
      if (notifyTime.isBefore(DateTime.now())) continue;

      final notificationId = _generateNotificationId(contest, offset);
      final title = _getNotificationTitle(contest, offset);
      final body = _getNotificationBody(contest, offset);

      await _scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledTime: notifyTime,
        payload: contest.url ?? '',
      );
    }
  }

  /// Cancel all notifications for a specific contest.
  Future<void> cancelContestNotifications(Contest contest) async {
    final offsets = [
      const Duration(hours: 24),
      const Duration(hours: 12),
      const Duration(hours: 5),
      const Duration(hours: 1),
      const Duration(minutes: 30),
      Duration.zero,
    ];

    for (final offset in offsets) {
      final id = _generateNotificationId(contest, offset);
      await _plugin.cancel(id);
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedule a single notification.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'contest_alerts',
          'Contest Alerts',
          channelDescription:
              'Notifications for upcoming competitive programming contests',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Generate a unique notification ID for a contest + offset combination.
  int _generateNotificationId(Contest contest, Duration offset) {
    return (contest.id.hashCode + offset.inMinutes).abs() % 2147483647;
  }

  /// Get the notification title based on offset.
  String _getNotificationTitle(Contest contest, Duration offset) {
    final platform = contest.platform.displayName;
    if (offset == Duration.zero) {
      return '🚀 $platform Contest LIVE NOW';
    }
    return '⏰ $platform Contest Alert';
  }

  /// Get the notification body based on offset.
  String _getNotificationBody(Contest contest, Duration offset) {
    final name = contest.name;

    if (offset == Duration.zero) {
      return '$name has started! Time to compete.';
    }

    String timeStr;
    if (offset.inHours >= 24) {
      timeStr = '24 hours';
    } else if (offset.inHours >= 12) {
      timeStr = '12 hours';
    } else if (offset.inHours >= 5) {
      timeStr = '5 hours';
    } else if (offset.inHours >= 1) {
      timeStr = '1 hour';
    } else {
      timeStr = '${offset.inMinutes} minutes';
    }

    return '$name starts in $timeStr. Get ready!';
  }

  /// Reschedule all notifications for a list of contests.
  Future<void> rescheduleAll(
    List<Contest> contests,
    NotificationSettings settings,
  ) async {
    await cancelAll();

    final upcomingContests =
        contests.where((c) => c.isUpcoming || c.isRunning);

    for (final contest in upcomingContests) {
      await scheduleContestNotifications(contest, settings);
    }
  }

  /// Request runtime permissions for notifications and exact alarms
  Future<void> requestPermissions() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  /// Send a test notification scheduled 5 seconds from now.
  Future<void> testNotification() async {
    await _scheduleNotification(
      id: 99999,
      title: '🧪 System Test',
      body: 'If you see this, push notifications are working!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      payload: 'test_payload',
    );
  }
}
