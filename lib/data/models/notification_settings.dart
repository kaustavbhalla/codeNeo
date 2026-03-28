/// Notification preferences model.
class NotificationSettings {
  bool masterEnabled;
  bool dayBefore;       // 24 hours
  bool twelveHours;     // 12 hours
  bool fiveHours;       // 5 hours
  bool oneHour;         // 1 hour
  bool thirtyMinutes;   // 30 minutes
  bool contestStart;    // 0 minutes

  // Per-platform toggles
  bool leetcodeEnabled;
  bool codeforcesEnabled;
  bool codechefEnabled;

  NotificationSettings({
    this.masterEnabled = true,
    this.dayBefore = true,
    this.twelveHours = true,
    this.fiveHours = true,
    this.oneHour = true,
    this.thirtyMinutes = true,
    this.contestStart = true,
    this.leetcodeEnabled = true,
    this.codeforcesEnabled = true,
    this.codechefEnabled = true,
  });

  /// Get the active notification offsets.
  List<Duration> get activeOffsets {
    if (!masterEnabled) return [];
    final offsets = <Duration>[];
    if (dayBefore) offsets.add(const Duration(hours: 24));
    if (twelveHours) offsets.add(const Duration(hours: 12));
    if (fiveHours) offsets.add(const Duration(hours: 5));
    if (oneHour) offsets.add(const Duration(hours: 1));
    if (thirtyMinutes) offsets.add(const Duration(minutes: 30));
    if (contestStart) offsets.add(Duration.zero);
    return offsets;
  }

  /// Check if a platform's notifications are enabled.
  bool isPlatformEnabled(String platform) {
    switch (platform) {
      case 'leetcode':
        return leetcodeEnabled;
      case 'codeforces':
        return codeforcesEnabled;
      case 'codechef':
        return codechefEnabled;
      default:
        return true;
    }
  }

  Map<String, dynamic> toJson() => {
    'masterEnabled': masterEnabled,
    'dayBefore': dayBefore,
    'twelveHours': twelveHours,
    'fiveHours': fiveHours,
    'oneHour': oneHour,
    'thirtyMinutes': thirtyMinutes,
    'contestStart': contestStart,
    'leetcodeEnabled': leetcodeEnabled,
    'codeforcesEnabled': codeforcesEnabled,
    'codechefEnabled': codechefEnabled,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        masterEnabled: json['masterEnabled'] as bool? ?? true,
        dayBefore: json['dayBefore'] as bool? ?? true,
        twelveHours: json['twelveHours'] as bool? ?? true,
        fiveHours: json['fiveHours'] as bool? ?? true,
        oneHour: json['oneHour'] as bool? ?? true,
        thirtyMinutes: json['thirtyMinutes'] as bool? ?? true,
        contestStart: json['contestStart'] as bool? ?? true,
        leetcodeEnabled: json['leetcodeEnabled'] as bool? ?? true,
        codeforcesEnabled: json['codeforcesEnabled'] as bool? ?? true,
        codechefEnabled: json['codechefEnabled'] as bool? ?? true,
      );
}
