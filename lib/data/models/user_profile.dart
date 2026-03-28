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
    contestsAttended: json['contestsAttended'] as int? ?? 0,
    avatarUrl: json['avatarUrl'] as String?,
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'] as String)
        : null,
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
  final int currentStreak;
  final List<int> activeYears;

  const ActivityData({
    required this.submissionCalendar,
    this.totalActiveDays = 0,
    this.currentStreak = 0,
    this.activeYears = const [],
  });
}
