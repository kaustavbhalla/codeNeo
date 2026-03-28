import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contest.dart';
import '../models/notification_settings.dart';
import '../services/codeforces_service.dart';
import '../services/leetcode_service.dart';
import '../services/codechef_service.dart';

/// Aggregates contests from all platforms.
class ContestRepository {
  final CodeforcesService _cfService;
  final LeetCodeService _lcService;
  final CodeChefService _ccService;

  ContestRepository({
    CodeforcesService? cfService,
    LeetCodeService? lcService,
    CodeChefService? ccService,
  })  : _cfService = cfService ?? CodeforcesService(),
        _lcService = lcService ?? LeetCodeService(),
        _ccService = ccService ?? CodeChefService();

  /// Fetch all contests from all platforms.
  Future<List<Contest>> fetchAllContests() async {
    final results = await Future.wait([
      _cfService.fetchContests(),
      _lcService.fetchContests(),
      _ccService.fetchContests(),
    ]);

    final allContests = <Contest>[];
    for (final platformContests in results) {
      allContests.addAll(platformContests);
    }

    // Load saved notification preferences
    await _loadNotificationPrefs(allContests);

    // Sort: upcoming first (by start time), then running, then past
    allContests.sort((a, b) {
      if (a.phase != b.phase) {
        return a.phase.index.compareTo(b.phase.index);
      }
      return a.startTime.compareTo(b.startTime);
    });

    return allContests;
  }

  /// Save notification preference for a contest.
  Future<void> saveNotificationPref(Contest contest, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notif_${contest.notificationKey}';
    await prefs.setBool(key, enabled);
  }

  Future<void> _loadNotificationPrefs(List<Contest> contests) async {
    final prefs = await SharedPreferences.getInstance();
    for (final contest in contests) {
      final key = 'notif_${contest.notificationKey}';
      contest.notificationsEnabled = prefs.getBool(key) ?? true;
    }
  }
}

/// Settings repository for notification preferences and user handles.
class SettingsRepository {
  static const _settingsKey = 'notification_settings';
  static const _handlesKey = 'user_handles';
  static const _onboardingKey = 'onboarding_complete';

  Future<NotificationSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_settingsKey);
    if (json != null) {
      return NotificationSettings.fromJson(jsonDecode(json));
    }
    return NotificationSettings();
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<Map<String, String>> loadHandles() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_handlesKey);
    if (json != null) {
      return Map<String, String>.from(jsonDecode(json));
    }
    return {};
  }

  Future<void> saveHandles(Map<String, String> handles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_handlesKey, jsonEncode(handles));
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
