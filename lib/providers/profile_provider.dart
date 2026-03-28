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
  ActivityData? _activityData;
  bool _isLoading = false;
  String? _error;
  Map<String, String> _handles = {};

  ProfileProvider({
    CodeforcesService? cfService,
    LeetCodeService? lcService,
    CodeChefService? ccService,
  })  : _cfService = cfService ?? CodeforcesService(),
        _lcService = lcService ?? LeetCodeService(),
        _ccService = ccService ?? CodeChefService();

  Map<Platform, UserProfile> get profiles => _profiles;
  Map<Platform, List<RatingChange>> get ratingHistories => _ratingHistories;
  ActivityData? get activityData => _activityData;
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

  void setHandles(Map<String, String> handles) {
    _handles = handles;
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
    final problemsSolved = await _cfService.fetchProblemsSolved(handle);

    if (profile != null) {
      _profiles[Platform.codeforces] = profile.copyWith(
        problemsSolved: problemsSolved,
      );
    }

    final history = await _cfService.fetchRatingHistory(handle);
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

    if (profile != null && contestInfo.profile != null) {
      _profiles[Platform.leetcode] = UserProfile(
        platform: Platform.leetcode,
        handle: handle,
        currentRating: contestInfo.profile!.currentRating,
        maxRating: contestInfo.profile!.maxRating,
        rank: contestInfo.profile!.rank,
        globalRank: profile.globalRank,
        problemsSolved: profile.problemsSolved,
        contestsAttended: contestInfo.profile!.contestsAttended,
        avatarUrl: profile.avatarUrl,
        lastUpdated: DateTime.now(),
      );
    } else if (profile != null) {
      _profiles[Platform.leetcode] = profile;
    }

    _ratingHistories[Platform.leetcode] = contestInfo.history;

    if (activity != null) {
      _activityData = activity;
    }
  }

  Future<void> _fetchCodeChefProfile(String handle) async {
    final profile = await _ccService.fetchUserProfile(handle);
    if (profile != null) {
      _profiles[Platform.codechef] = profile;
    }

    final history = await _ccService.fetchRatingHistory(handle);
    _ratingHistories[Platform.codechef] = history;
  }
}
