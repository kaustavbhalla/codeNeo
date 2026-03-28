import 'package:flutter/material.dart';
import '../data/models/contest.dart';
import '../data/models/notification_settings.dart';
import '../data/repositories/contest_repository.dart';
import '../data/services/notification_service.dart';
import '../core/utils/platform_utils.dart';

/// State management for contests.
class ContestProvider extends ChangeNotifier {
  final ContestRepository _repository;
  final NotificationService _notificationService;

  List<Contest> _contests = [];
  bool _isLoading = false;
  String? _error;
  Platform? _filterPlatform;

  ContestProvider({
    ContestRepository? repository,
    NotificationService? notificationService,
  })  : _repository = repository ?? ContestRepository(),
        _notificationService = notificationService ?? NotificationService();

  List<Contest> get contests => _filterPlatform == null
      ? _contests
      : _contests.where((c) => c.platform == _filterPlatform).toList();

  List<Contest> get upcomingContests =>
      contests.where((c) => c.isUpcoming || c.isRunning).toList();

  List<Contest> get pastContests =>
      contests.where((c) => c.isFinished).toList();

  Contest? get nextContest =>
      upcomingContests.isNotEmpty ? upcomingContests.first : null;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Platform? get filterPlatform => _filterPlatform;

  int get totalUpcoming => upcomingContests.length;

  void setFilter(Platform? platform) {
    _filterPlatform = platform;
    notifyListeners();
  }

  /// Fetch all contests from all platforms.
  Future<void> fetchContests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contests = await _repository.fetchAllContests();
    } catch (e) {
      _error = 'Failed to fetch contests: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle notification for a specific contest.
  Future<void> toggleContestNotification(
    Contest contest,
    NotificationSettings settings,
  ) async {
    contest.notificationsEnabled = !contest.notificationsEnabled;
    await _repository.saveNotificationPref(
      contest,
      contest.notificationsEnabled,
    );

    if (contest.notificationsEnabled) {
      await _notificationService.scheduleContestNotifications(
        contest,
        settings,
      );
    } else {
      await _notificationService.cancelContestNotifications(contest);
    }

    notifyListeners();
  }

  /// Reschedule all notifications based on current settings.
  Future<void> rescheduleNotifications(NotificationSettings settings) async {
    await _notificationService.rescheduleAll(_contests, settings);
  }
}
