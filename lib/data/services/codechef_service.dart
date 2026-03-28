import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/platform_utils.dart';
import '../models/contest.dart';
import '../models/user_profile.dart';

/// CodeChef API client (community wrapper + semi-official contest endpoint).
class CodeChefService {
  final http.Client _client;

  CodeChefService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch CodeChef contests.
  Future<List<Contest>> fetchContests() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.codechefContests),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final contests = <Contest>[];

      // Present (running) contests
      final present = data['present_contests'] as List? ?? [];
      for (final c in present) {
        contests.add(_parseContest(c, ContestPhase.running));
      }

      // Future (upcoming) contests
      final future = data['future_contests'] as List? ?? [];
      for (final c in future) {
        contests.add(_parseContest(c, ContestPhase.upcoming));
      }

      // Past contests (recent only)
      final past = data['past_contests'] as List? ?? [];
      for (int i = 0; i < past.length && i < 10; i++) {
        contests.add(_parseContest(past[i], ContestPhase.finished));
      }

      return contests;
    } catch (e) {
      return [];
    }
  }

  Contest _parseContest(Map<String, dynamic> c, ContestPhase phase) {
    final code = c['contest_code'] as String? ?? '';
    final name = c['contest_name'] as String? ?? code;

    DateTime startTime;
    try {
      final startDate = c['contest_start_date'] as String? ??
          c['contest_start_date_iso'] as String? ??
          '';
      startTime = DateTime.parse(startDate).toUtc();
    } catch (_) {
      startTime = DateTime.now().toUtc();
    }

    Duration duration;
    try {
      final durationMinutes = c['contest_duration'] as String? ?? '0';
      duration = Duration(minutes: int.tryParse(durationMinutes) ?? 0);
    } catch (_) {
      duration = const Duration(hours: 2);
    }

    return Contest(
      id: 'cc_$code',
      name: name,
      platform: Platform.codechef,
      startTime: startTime,
      duration: duration,
      url: '${ApiConstants.codechefContestUrl}/$code',
      phase: phase,
    );
  }

  /// Fetch user profile from community API.
  Future<UserProfile?> fetchUserProfile(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.codechefApi}/$handle'),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data['success'] == false) return null;

      return UserProfile(
        platform: Platform.codechef,
        handle: handle,
        currentRating: data['currentRating'] as int? ?? 0,
        maxRating: data['highestRating'] as int? ?? 0,
        rank: '${data['stars'] ?? '★'}',
        globalRank: data['globalRank'] as int? ?? 0,
        problemsSolved: _countSolved(data),
        avatarUrl: data['profile'] as String?,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch rating history from community API.
  Future<List<RatingChange>> fetchRatingHistory(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.codechefApi}/$handle'),
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final ratingData = data['ratingData'] as List? ?? [];

      final history = <RatingChange>[];
      int prevRating = 1500;

      for (final r in ratingData) {
        final rating = int.tryParse(r['rating']?.toString() ?? '0') ?? 0;
        final name = r['name'] as String? ??
            r['code'] as String? ??
            'Unknown';

        history.add(RatingChange(
          contestName: name,
          contestId: 0,
          newRating: rating,
          oldRating: prevRating,
          rank: int.tryParse(r['rank']?.toString() ?? '0') ?? 0,
          timestamp: DateTime.tryParse(
                  r['end_date'] as String? ?? r['getmonth'] as String? ?? '') ??
              DateTime.now(),
          platform: Platform.codechef,
        ));
        prevRating = rating;
      }

      return history;
    } catch (e) {
      return [];
    }
  }

  int _countSolved(Map<String, dynamic> data) {
    // The community API might return this differently
    if (data['fullySolved'] != null) {
      return data['fullySolved'] as int? ?? 0;
    }
    if (data['problemsSolved'] != null) {
      return data['problemsSolved'] as int? ?? 0;
    }
    return 0;
  }
}
