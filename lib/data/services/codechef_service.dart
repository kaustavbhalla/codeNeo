import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/platform_utils.dart';
import '../models/contest.dart';
import '../models/user_profile.dart';

/// CodeChef API client (HTML scraping + semi-official contest endpoint).
class CodeChefService {
  final http.Client _client;

  CodeChefService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch user profile by scraping the CodeChef profile page.
  Future<UserProfile?> fetchUserProfile(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.codechefProfileUrl}/$handle'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      );

      if (response.statusCode != 200) return null;

      final html = response.body;

      // Extract all_rating JSON from the script tag
      final allRating = _extractAllRating(html);

      // Current rating — last entry in all_rating, or from rating-number div
      int currentRating = 0;
      if (allRating.isNotEmpty) {
        currentRating =
            int.tryParse(allRating.last['rating']?.toString() ?? '0') ?? 0;
      }
      currentRating = _extractRatingNumber(html) ?? currentRating;

      // Highest rating
      int maxRating = _extractHighestRating(html) ?? 0;
      if (maxRating == 0 && allRating.isNotEmpty) {
        maxRating = allRating
            .map((e) => int.tryParse(e['rating']?.toString() ?? '0') ?? 0)
            .fold(0, (a, b) => a > b ? a : b);
      }

      // Stars
      final stars = _extractStars(html);

      // Global rank (may be "Inactive" for inactive users)
      final globalRank = _extractGlobalRank(html);

      // Contests attended
      final contestsAttended = _extractContestsCount(html);

      // Avatar URL
      final avatarUrl = _extractAvatarUrl(html);

      return UserProfile(
        platform: Platform.codechef,
        handle: handle,
        currentRating: currentRating,
        maxRating: maxRating,
        rank: stars,
        globalRank: globalRank,
        problemsSolved: 0, // Not reliably available from profile page
        contestsAttended: contestsAttended,
        avatarUrl: avatarUrl,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch rating history by scraping the CodeChef profile page.
  Future<List<RatingChange>> fetchRatingHistory(String handle) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.codechefProfileUrl}/$handle'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      );

      if (response.statusCode != 200) return [];

      final allRating = _extractAllRating(response.body);
      if (allRating.isEmpty) return [];

      final history = <RatingChange>[];
      int prevRating = 1500;

      for (final r in allRating) {
        final rating = int.tryParse(r['rating']?.toString() ?? '0') ?? 0;
        final name = r['name'] as String? ??
            r['code'] as String? ??
            'Unknown';

        DateTime timestamp;
        try {
          timestamp =
              DateTime.parse(r['end_date'] as String? ?? '').toUtc();
        } catch (_) {
          timestamp = DateTime.now().toUtc();
        }

        history.add(RatingChange(
          contestName: name,
          contestId: 0,
          newRating: rating,
          oldRating: prevRating,
          rank: int.tryParse(r['rank']?.toString() ?? '0') ?? 0,
          timestamp: timestamp,
          platform: Platform.codechef,
        ));
        prevRating = rating;
      }

      return history;
    } catch (e) {
      return [];
    }
  }

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
      // Try ISO format first — it's parseable by DateTime.parse()
      final startDate = c['contest_start_date_iso'] as String? ??
          c['contest_start_date'] as String? ??
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

  // ─── HTML Parsing Helpers ───

  /// Extract the `all_rating` JSON array from the embedded script.
  List<Map<String, dynamic>> _extractAllRating(String html) {
    try {
      final pattern = RegExp(r'var\s+all_rating\s*=\s*(\[.*?\]);',
          dotAll: true);
      final match = pattern.firstMatch(html);
      if (match == null) return [];

      final jsonStr = match.group(1);
      if (jsonStr == null) return [];

      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Extract current rating from `<div class="rating-number">`.
  int? _extractRatingNumber(String html) {
    try {
      final pattern = RegExp(
          r'<div\s+class="rating-number">\s*(\d+)\s*</div>');
      final match = pattern.firstMatch(html);
      if (match == null) return null;
      return int.tryParse(match.group(1)!);
    } catch (_) {
      return null;
    }
  }

  /// Extract highest rating from `(Highest Rating X)`.
  int? _extractHighestRating(String html) {
    try {
      final pattern = RegExp(r'Highest\s+Rating\s+(\d+)');
      final match = pattern.firstMatch(html);
      if (match == null) return null;
      return int.tryParse(match.group(1)!);
    } catch (_) {
      return null;
    }
  }

  /// Extract star count from colored star spans.
  String _extractStars(String html) {
    try {
      final pattern = RegExp(
          r'<div\s+class="rating-star">\s*((?:<span[^>]*>★</span>\s*)+)</div>');
      final match = pattern.firstMatch(html);
      if (match == null) return '★';

      final starHtml = match.group(1) ?? '';
      final starCount = '★'.allMatches(starHtml).length;
      if (starCount == 0) return '★';
      return '★' * starCount;
    } catch (_) {
      return '★';
    }
  }

  /// Extract global rank from `<strong class='global-rank'>`.
  /// Returns 0 if rank is "Inactive" or not a number.
  int _extractGlobalRank(String html) {
    try {
      final pattern = RegExp(
          '<strong\\s+class=[\'"]global-rank[\'"]>\\s*(\\d+)\\s*</strong>');
      final match = pattern.firstMatch(html);
      if (match == null) return 0;
      return int.tryParse(match.group(1)!) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Extract contests attended from `<h3>Contests (N)</h3>`.
  int _extractContestsCount(String html) {
    try {
      final pattern = RegExp(r'<h3>\s*Contests\s*\((\d+)\)');
      final match = pattern.firstMatch(html);
      if (match == null) return 0;
      return int.tryParse(match.group(1)!) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Extract avatar URL from the profile page.
  String? _extractAvatarUrl(String html) {
    try {
      // Look for profile image in the page
      final pattern = RegExp(
          '<img[^>]+src=["\']([^"\']*(?:avatar|profile|gravatar)[^"\']*)["\']',
          caseSensitive: false);
      var match = pattern.firstMatch(html);
      if (match != null) return match.group(1);

      // Fallback: look for the user image class
      final fallback = RegExp(
          '<img[^>]+class=["\'][^"\']*user[^"\']*["\'][^>]+src=["\']([^"\']+)["\']',
          caseSensitive: false);
      match = fallback.firstMatch(html);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }
}
