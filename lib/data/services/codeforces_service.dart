import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/platform_utils.dart';
import '../models/contest.dart';
import '../models/user_profile.dart';

/// Codeforces REST API client.
class CodeforcesService {
  final http.Client _client;

  CodeforcesService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all contests (upcoming + past).
  Future<List<Contest>> fetchContests() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.cfContestList}?gym=false'),
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data['status'] != 'OK') return [];

      final results = data['result'] as List;
      return results.map<Contest>((c) {
        final phase = _mapPhase(c['phase'] as String);
        final startTimeSeconds = c['startTimeSeconds'] as int? ?? 0;
        final durationSeconds = c['durationSeconds'] as int? ?? 0;

        return Contest(
          id: 'cf_${c['id']}',
          name: c['name'] as String,
          platform: Platform.codeforces,
          startTime: DateTime.fromMillisecondsSinceEpoch(
            startTimeSeconds * 1000,
            isUtc: true,
          ),
          duration: Duration(seconds: durationSeconds),
          url: '${ApiConstants.cfContestUrl}/${c['id']}',
          phase: phase,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch user information (rating, rank, etc.)
  Future<UserProfile?> fetchUserInfo(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.cfUserInfo}?handles=$handle'),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data['status'] != 'OK') return null;

      final user = (data['result'] as List).first;
      return UserProfile(
        platform: Platform.codeforces,
        handle: handle,
        currentRating: user['rating'] as int? ?? 0,
        maxRating: user['maxRating'] as int? ?? 0,
        rank: (user['rank'] as String? ?? 'Unrated').toUpperCase(),
        globalRank: 0, // Not available in user.info
        avatarUrl: user['titlePhoto'] as String?,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch the number of unique problems solved via user.status.
  Future<int> fetchProblemsSolved(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.codeforcesBase}/user.status?handle=$handle'),
      );

      if (response.statusCode != 200) return 0;

      final data = jsonDecode(response.body);
      if (data['status'] != 'OK') return 0;

      final submissions = data['result'] as List;
      final solved = <String>{};
      for (final s in submissions) {
        if (s['verdict'] == 'OK') {
          final problem = s['problem'];
          final key = '${problem['contestId']}-${problem['index']}';
          solved.add(key);
        }
      }
      return solved.length;
    } catch (e) {
      return 0;
    }
  }

  /// Fetch user rating history.
  Future<List<RatingChange>> fetchRatingHistory(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.cfUserRating}?handle=$handle'),
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data['status'] != 'OK') return [];

      final results = data['result'] as List;
      return results.map<RatingChange>((r) {
        return RatingChange(
          contestName: r['contestName'] as String,
          contestId: r['contestId'] as int,
          newRating: r['newRating'] as int,
          oldRating: r['oldRating'] as int,
          rank: r['rank'] as int,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            (r['ratingUpdateTimeSeconds'] as int) * 1000,
            isUtc: true,
          ),
          platform: Platform.codeforces,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  ContestPhase _mapPhase(String phase) {
    switch (phase) {
      case 'BEFORE':
        return ContestPhase.upcoming;
      case 'CODING':
      case 'PENDING_SYSTEM_TEST':
      case 'SYSTEM_TEST':
        return ContestPhase.running;
      default:
        return ContestPhase.finished;
    }
  }
}
