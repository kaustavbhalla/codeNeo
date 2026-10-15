import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/platform_utils.dart';
import '../models/contest.dart';
import '../models/user_profile.dart';

/// LeetCode GraphQL API client.
class LeetCodeService {
  final http.Client _client;

  LeetCodeService({http.Client? client}) : _client = client ?? http.Client();

  /// Execute a GraphQL query against LeetCode.
  Future<Map<String, dynamic>?> _graphql(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.leetcodeGraphQL),
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://leetcode.com',
        },
        body: jsonEncode({
          'query': query,
          if (variables != null) 'variables': variables,
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return data['data'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Fetch upcoming LeetCode contests.
  Future<List<Contest>> fetchContests() async {
    try {
      final data = await _graphql(LeetCodeQueries.upcomingContests);
      if (data == null) return [];

      final contests = data['topTwoContests'] as List? ?? [];
      return contests.map<Contest>((c) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(
          (c['startTime'] as int) * 1000,
          isUtc: true,
        );
        final now = DateTime.now().toUtc();
        final phase = startTime.isAfter(now)
            ? ContestPhase.upcoming
            : ContestPhase.running;

        return Contest(
          id: 'lc_${c['titleSlug']}',
          name: c['title'] as String,
          platform: Platform.leetcode,
          startTime: startTime,
          duration: Duration(seconds: c['duration'] as int? ?? 5400),
          url: '${ApiConstants.leetcodeContestUrl}/${c['titleSlug']}',
          phase: phase,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch user profile (solved counts, ranking).
  Future<UserProfile?> fetchUserProfile(String username) async {
    try {
      final data = await _graphql(
        LeetCodeQueries.userProfile,
        variables: {'username': username},
      );
      if (data == null || data['matchedUser'] == null) return null;

      final user = data['matchedUser'];
      final profile = user['profile'] as Map<String, dynamic>? ?? {};
      final stats = user['submitStatsGlobal']?['acSubmissionNum'] as List? ?? [];

      int totalSolved = 0;
      int? acceptedSubmissions;
      for (final s in stats) {
        if (s['difficulty'] == 'All') {
          totalSolved = s['count'] as int? ?? 0;
          acceptedSubmissions = s['submissions'] as int?;
        }
      }
      int? totalSubmissions;
      for (final s
          in user['submitStatsGlobal']?['totalSubmissionNum'] as List? ?? []) {
        if (s['difficulty'] == 'All') {
          totalSubmissions = s['submissions'] as int?;
        }
      }

      return UserProfile(
        platform: Platform.leetcode,
        handle: username,
        currentRating: 0, // Will be filled by contest info
        globalRank: profile['ranking'] as int? ?? 0,
        problemsSolved: totalSolved,
        submissionStats:
            acceptedSubmissions != null && totalSubmissions != null
                ? SubmissionStats(
                  accepted: acceptedSubmissions,
                  total: totalSubmissions,
                )
                : null,
        avatarUrl: profile['userAvatar'] as String?,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch contest rating info and history.
  Future<({UserProfile? profile, List<RatingChange> history})>
      fetchContestInfo(String username) async {
    try {
      final data = await _graphql(
        LeetCodeQueries.userContestInfo,
        variables: {'username': username},
      );
      if (data == null) return (profile: null, history: <RatingChange>[]);

      UserProfile? profile;
      final ranking = data['userContestRanking'];
      if (ranking != null) {
        profile = UserProfile(
          platform: Platform.leetcode,
          handle: username,
          currentRating: (ranking['rating'] as num?)?.toInt() ?? 0,
          maxRating: (ranking['rating'] as num?)?.toInt() ?? 0,
          rank: 'TOP ${(ranking['topPercentage'] as num?)?.toStringAsFixed(1) ?? '0'}%',
          globalRank: ranking['globalRanking'] as int? ?? 0,
          contestsAttended: ranking['attendedContestsCount'] as int? ?? 0,
          lastUpdated: DateTime.now(),
        );
      }

      final historyData = data['userContestRankingHistory'] as List? ?? [];
      final history = <RatingChange>[];
      double prevRating = 1500;

      for (final h in historyData) {
        if (h['attended'] != true) continue;
        final contest = h['contest'] as Map<String, dynamic>? ?? {};
        final rating = (h['rating'] as num?)?.toDouble() ?? 0;

        history.add(RatingChange(
            contestName: contest['title'] as String? ?? 'Unknown',
            contestId: 0,
            newRating: rating.toInt(),
            oldRating: prevRating.toInt(),
            rank: h['ranking'] as int? ?? 0,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              ((contest['startTime'] as int?) ?? 0) * 1000,
              isUtc: true,
            ),
            platform: Platform.leetcode,
          ));
        prevRating = rating;
      }

      return (profile: profile, history: history);
    } catch (e) {
      return (profile: null, history: <RatingChange>[]);
    }
  }

  /// Fetch activity calendar for heatmap.
  Future<ActivityData?> fetchActivityCalendar(String username, {int? year, DateTime? now}) async {
    try {
      // Load every calendar year touched by the displayed 180-day window.
      if (year == null) {
        final today = ActivityData.day(now ?? DateTime.now());
        final firstDay = today.subtract(const Duration(days: 179));
        final calendars = await Future.wait([
          for (var y = firstDay.year; y <= today.year; y++)
            fetchActivityCalendar(username, year: y),
        ]);
        if (calendars.any((calendar) => calendar == null)) return null;
        final merged = <DateTime, int>{};
        final activeYears = <int>{};
        var longestStreak = 0;
        for (final calendar in calendars.cast<ActivityData>()) {
          merged.addAll(calendar.submissionCalendar);
          activeYears.addAll(calendar.activeYears);
          if (calendar.longestStreak > longestStreak) {
            longestStreak = calendar.longestStreak;
          }
        }
        return ActivityData(
          submissionCalendar: merged,
          totalActiveDays: merged.values.where((count) => count > 0).length,
          longestStreak: longestStreak,
          activeYears: activeYears.toList()..sort(),
        );
      }
      final data = await _graphql(
        LeetCodeQueries.userCalendar,
        variables: {'username': username, 'year': year},
      );
      if (data == null || data['matchedUser'] == null) return null;

      final calendar = data['matchedUser']['userCalendar'];
      if (calendar == null) return null;

      final submissionStr = calendar['submissionCalendar'] as String? ?? '{}';
      final submissionMap = jsonDecode(submissionStr) as Map<String, dynamic>;

      final calendarData = <DateTime, int>{};
      for (final entry in submissionMap.entries) {
        final timestamp = int.tryParse(entry.key);
        final count = entry.value as int? ?? 0;
        if (timestamp == null || count <= 0) continue;
        final date = DateTime.fromMillisecondsSinceEpoch(
          timestamp * 1000,
          isUtc: true,
        );
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        calendarData.update(
          normalizedDate,
          (value) => value + count,
          ifAbsent: () => count,
        );
      }

      return ActivityData(
        submissionCalendar: calendarData,
        totalActiveDays: calendar['totalActiveDays'] as int? ?? 0,
        longestStreak: calendar['streak'] as int? ?? 0,
        activeYears:
            (calendar['activeYears'] as List?)?.map((e) => e as int).toList() ??
            [],
      );
    } catch (e) {
      return null;
    }
  }
}
