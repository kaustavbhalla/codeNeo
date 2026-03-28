import '../../core/utils/platform_utils.dart';

/// Represents a competitive programming contest.
class Contest {
  final String id;
  final String name;
  final Platform platform;
  final DateTime startTime;
  final Duration duration;
  final String? url;
  final ContestPhase phase;
  bool notificationsEnabled;

  Contest({
    required this.id,
    required this.name,
    required this.platform,
    required this.startTime,
    required this.duration,
    this.url,
    required this.phase,
    this.notificationsEnabled = true,
  });

  DateTime get endTime => startTime.add(duration);

  bool get isUpcoming => phase == ContestPhase.upcoming;
  bool get isRunning => phase == ContestPhase.running;
  bool get isFinished => phase == ContestPhase.finished;

  /// Unique key for notification scheduling.
  String get notificationKey => '${platform.shortName}_$id';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platform': platform.name,
    'startTime': startTime.toIso8601String(),
    'duration': duration.inSeconds,
    'url': url,
    'phase': phase.name,
    'notificationsEnabled': notificationsEnabled,
  };

  factory Contest.fromJson(Map<String, dynamic> json) => Contest(
    id: json['id'] as String,
    name: json['name'] as String,
    platform: Platform.values.firstWhere((p) => p.name == json['platform']),
    startTime: DateTime.parse(json['startTime'] as String),
    duration: Duration(seconds: json['duration'] as int),
    url: json['url'] as String?,
    phase: ContestPhase.values.firstWhere((p) => p.name == json['phase']),
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contest && runtimeType == other.runtimeType && id == other.id && platform == other.platform;

  @override
  int get hashCode => id.hashCode ^ platform.hashCode;
}
