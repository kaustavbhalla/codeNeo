import '../../core/utils/platform_utils.dart';

/// User profile data for a single platform.
class UserProfile {
  final Platform platform;
  final String handle;
  final int currentRating;
  final int maxRating;
  final String rank;
  final int globalRank;
  final int problemsSolved;
  final SubmissionStats? submissionStats;
  final ActivityData? activityData;
  final int contestsAttended;
  final String? avatarUrl;
  final DateTime? lastUpdated;

  const UserProfile({
    required this.platform,
    required this.handle,
    this.currentRating = 0,
    this.maxRating = 0,
    this.rank = 'Unrated',
    this.globalRank = 0,
    this.problemsSolved = 0,
    this.submissionStats,
    this.activityData,
    this.contestsAttended = 0,
    this.avatarUrl,
    this.lastUpdated,
  });

  UserProfile copyWith({
    int? currentRating,
    int? maxRating,
    String? rank,
    int? globalRank,
    int? problemsSolved,
    SubmissionStats? submissionStats,
    ActivityData? activityData,
    int? contestsAttended,
    String? avatarUrl,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      platform: platform,
      handle: handle,
      currentRating: currentRating ?? this.currentRating,
      maxRating: maxRating ?? this.maxRating,
      rank: rank ?? this.rank,
      globalRank: globalRank ?? this.globalRank,
      problemsSolved: problemsSolved ?? this.problemsSolved,
      submissionStats: submissionStats ?? this.submissionStats,
      activityData: activityData ?? this.activityData,
      contestsAttended: contestsAttended ?? this.contestsAttended,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform.name,
    'handle': handle,
    'currentRating': currentRating,
    'maxRating': maxRating,
    'rank': rank,
    'globalRank': globalRank,
    'problemsSolved': problemsSolved,
    'submissionStats': submissionStats?.toJson(),
    'activityData': activityData?.toJson(),
    'contestsAttended': contestsAttended,
    'avatarUrl': avatarUrl,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    platform: Platform.values.firstWhere((p) => p.name == json['platform']),
    handle: json['handle'] as String,
    currentRating: json['currentRating'] as int? ?? 0,
    maxRating: json['maxRating'] as int? ?? 0,
    rank: json['rank'] as String? ?? 'Unrated',
    globalRank: json['globalRank'] as int? ?? 0,
    problemsSolved: json['problemsSolved'] as int? ?? 0,
    submissionStats:
        json['submissionStats'] == null
            ? null
            : SubmissionStats.fromJson(
              json['submissionStats'] as Map<String, dynamic>,
            ),
    contestsAttended: json['contestsAttended'] as int? ?? 0,
    activityData:
        json['activityData'] == null
            ? null
            : ActivityData.fromJson(
              json['activityData'] as Map<String, dynamic>,
            ),
    avatarUrl: json['avatarUrl'] as String?,
    lastUpdated:
        json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : null,
  );
}

/// Submission attempts, including repeated attempts on the same problem.
class SubmissionStats {
  final int accepted;
  final int total;

  const SubmissionStats({required this.accepted, required this.total});

  double? get acceptanceRate => total > 0 ? accepted * 100 / total : null;

  Map<String, dynamic> toJson() => {'accepted': accepted, 'total': total};

  factory SubmissionStats.fromJson(Map<String, dynamic> json) =>
      SubmissionStats(
        accepted: json['accepted'] as int,
        total: json['total'] as int,
      );
}

/// Rating change entry from a specific contest.
class RatingChange {
  final String contestName;
  final int contestId;
  final int newRating;
  final int oldRating;
  final int rank;
  final DateTime timestamp;
  final Platform platform;

  const RatingChange({
    required this.contestName,
    required this.contestId,
    required this.newRating,
    required this.oldRating,
    required this.rank,
    required this.timestamp,
    required this.platform,
  });

  int get ratingChange => newRating - oldRating;
  bool get isPositive => ratingChange > 0;
}

/// Activity data for heatmap.
class ActivityData {
  final Map<DateTime, int> submissionCalendar;
  final int totalActiveDays;
  final int longestStreak;
  final List<int> activeYears;

  const ActivityData({
    required this.submissionCalendar,
    this.totalActiveDays = 0,
    this.longestStreak = 0,
    this.activeYears = const [],
  });

  /// Date-only keys use UTC to avoid device-timezone offsets in calendar lookup.
  static DateTime day(DateTime date) {
    final utc = date.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  int get currentStreak => currentStreakAt(DateTime.now());

  Map<String, dynamic> toJson() => {
    'submissionCalendar': submissionCalendar.map(
      (date, count) => MapEntry(date.toIso8601String(), count),
    ),
    'totalActiveDays': totalActiveDays,
    'longestStreak': longestStreak,
    'activeYears': activeYears,
  };

  factory ActivityData.fromJson(Map<String, dynamic> json) => ActivityData(
    submissionCalendar: (json['submissionCalendar'] as Map<String, dynamic>)
        .map((date, count) => MapEntry(DateTime.parse(date), count as int)),
    totalActiveDays: json['totalActiveDays'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    activeYears: (json['activeYears'] as List? ?? []).cast<int>(),
  );

  /// A streak remains active until today ends, so yesterday can be its last day.
  int currentStreakAt(DateTime now) {
    var date = day(now);
    if ((submissionCalendar[date] ?? 0) == 0) {
      date = date.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while ((submissionCalendar[date] ?? 0) > 0) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int activeDaysBetween(DateTime start, DateTime end) =>
      submissionCalendar.entries
          .where(
            (entry) =>
                entry.value > 0 &&
                !entry.key.isBefore(day(start)) &&
                !entry.key.isAfter(day(end)),
          )
          .length;
}
