import 'package:flutter/material.dart';
import '../data/models/user_profile.dart';
import '../data/services/codeforces_service.dart';
import '../data/services/leetcode_service.dart';
import '../data/services/codechef_service.dart';
import '../core/utils/platform_utils.dart';

/// State management for user profiles across platforms.
class ProfileProvider extends ChangeNotifier {
  final CodeforcesService _cfService;
  final LeetCodeService _lcService;
  final CodeChefService _ccService;

  final Map<Platform, UserProfile> _profiles = {};
  final Map<Platform, List<RatingChange>> _ratingHistories = {};
  bool _isLoading = false;
  String? _error;
  Map<String, String> _handles = {};

  ProfileProvider({
    CodeforcesService? cfService,
    LeetCodeService? lcService,
    CodeChefService? ccService,
  }) : _cfService = cfService ?? CodeforcesService(),
       _lcService = lcService ?? LeetCodeService(),
       _ccService = ccService ?? CodeChefService();

  Map<Platform, UserProfile> get profiles => _profiles;
  Map<Platform, List<RatingChange>> get ratingHistories => _ratingHistories;
  List<Platform> get activityPlatforms =>
      Platform.values
          .where((platform) => _profiles[platform]?.activityData != null)
          .toList();

  List<Platform> get missingActivityPlatforms =>
      Platform.values
          .where(
            (platform) =>
                (_handles[platform.name]?.isNotEmpty ?? false) &&
                !activityPlatforms.contains(platform),
          )
          .toList();

  ActivityData? get activityData {
    if (activityPlatforms.isEmpty) return null;
    final merged = <DateTime, int>{};
    for (final platform in activityPlatforms) {
      for (final entry
          in _profiles[platform]!.activityData!.submissionCalendar.entries) {
        merged.update(
          entry.key,
          (count) => count + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }
    return ActivityData(
      submissionCalendar: merged,
      totalActiveDays: merged.values.where((count) => count > 0).length,
    );
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get handles => _handles;

  UserProfile? getProfile(Platform platform) => _profiles[platform];
  List<RatingChange> getRatingHistory(Platform platform) =>
      _ratingHistories[platform] ?? [];

  /// Total problems solved across all platforms.
  int get totalSolved =>
      _profiles.values.fold(0, (sum, p) => sum + p.problemsSolved);

  /// Total contests attended across all platforms.
  int get totalContests =>
      _profiles.values.fold(0, (sum, p) => sum + p.contestsAttended);

  List<UserProfile> get submissionProfiles =>
      Platform.values
          .map((platform) => _profiles[platform])
          .whereType<UserProfile>()
          .where((profile) => profile.submissionStats != null)
          .toList();

  SubmissionStats? get submissionStats {
    final available = submissionProfiles;
    if (available.isEmpty) return null;
    return SubmissionStats(
      accepted: available.fold(
        0,
        (sum, profile) => sum + profile.submissionStats!.accepted,
      ),
      total: available.fold(
        0,
        (sum, profile) => sum + profile.submissionStats!.total,
      ),
    );
  }

  void setHandles(Map<String, String> handles) {
    for (final platform in Platform.values) {
      if (_handles[platform.name] != handles[platform.name]) {
        _profiles.remove(platform);
        _ratingHistories.remove(platform);
      }
    }
    _handles = Map.of(handles);
  }

  /// Fetch all profile data.
  Future<void> fetchAllProfiles() async {
    if (_handles.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final futures = <Future>[];

      // Codeforces
      final cfHandle = _handles['codeforces'];
      if (cfHandle != null && cfHandle.isNotEmpty) {
        futures.add(_fetchCodeforcesProfile(cfHandle));
      }

      // LeetCode
      final lcHandle = _handles['leetcode'];
      if (lcHandle != null && lcHandle.isNotEmpty) {
        futures.add(_fetchLeetCodeProfile(lcHandle));
      }

      // CodeChef
      final ccHandle = _handles['codechef'];
      if (ccHandle != null && ccHandle.isNotEmpty) {
        futures.add(_fetchCodeChefProfile(ccHandle));
      }

      await Future.wait(futures);
    } catch (e) {
      _error = 'Failed to fetch profiles: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchCodeforcesProfile(String handle) async {
    final profile = await _cfService.fetchUserInfo(handle);
    final summary = await _cfService.fetchSubmissionSummary(handle);
    if (_handles['codeforces'] != handle) return;

    if (profile != null) {
      _profiles[Platform.codeforces] = profile.copyWith(
        problemsSolved: summary?.solved,
        submissionStats: summary?.stats,
        activityData: summary?.activity,
      );
    }

    final history = await _cfService.fetchRatingHistory(handle);
    if (_handles['codeforces'] != handle) return;
    _ratingHistories[Platform.codeforces] = history;

    // Merge contest count from history
    if (_profiles.containsKey(Platform.codeforces) && history.isNotEmpty) {
      _profiles[Platform.codeforces] = _profiles[Platform.codeforces]!.copyWith(
        contestsAttended: history.length,
      );
    }
  }

  Future<void> _fetchLeetCodeProfile(String handle) async {
    final profile = await _lcService.fetchUserProfile(handle);
    final contestInfo = await _lcService.fetchContestInfo(handle);
    final activity = await _lcService.fetchActivityCalendar(handle);
    if (_handles['leetcode'] != handle) return;

    if (profile != null && contestInfo.profile != null) {
      _profiles[Platform.leetcode] = UserProfile(
        platform: Platform.leetcode,
        handle: handle,
        currentRating: contestInfo.profile!.currentRating,
        maxRating: contestInfo.profile!.maxRating,
        rank: contestInfo.profile!.rank,
        globalRank: profile.globalRank,
        problemsSolved: profile.problemsSolved,
        submissionStats: profile.submissionStats,
        activityData: activity,
        contestsAttended: contestInfo.profile!.contestsAttended,
        avatarUrl: profile.avatarUrl,
        lastUpdated: DateTime.now(),
      );
    } else if (profile != null) {
      _profiles[Platform.leetcode] = profile.copyWith(activityData: activity);
    }

    _ratingHistories[Platform.leetcode] = contestInfo.history;
  }

  Future<void> _fetchCodeChefProfile(String handle) async {
    final profile = await _ccService.fetchUserProfile(handle);
    if (_handles['codechef'] != handle) return;
    final stats =
        profile == null ? null : await _ccService.fetchSubmissionStats(handle);
    if (_handles['codechef'] != handle) return;
    if (profile != null) {
      _profiles[Platform.codechef] = profile.copyWith(submissionStats: stats);
    }

    final history = await _ccService.fetchRatingHistory(handle);
    if (_handles['codechef'] != handle) return;
    _ratingHistories[Platform.codechef] = history;
  }
}
