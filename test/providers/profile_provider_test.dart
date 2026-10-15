import 'dart:async';
import 'package:contest_tracker/core/theme/app_typography.dart';
import 'package:contest_tracker/core/utils/platform_utils.dart';
import 'package:contest_tracker/data/models/user_profile.dart';
import 'package:contest_tracker/data/services/codechef_service.dart';
import 'package:contest_tracker/data/services/codeforces_service.dart';
import 'package:contest_tracker/data/services/leetcode_service.dart';
import 'package:contest_tracker/providers/profile_provider.dart';
import 'package:contest_tracker/providers/settings_provider.dart';
import 'package:contest_tracker/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _LeetCode extends LeetCodeService {
  Completer<ActivityData?>? pending;
  final activity = ActivityData(
    submissionCalendar: {DateTime.utc(2026, 10, 15): 1},
  );

  @override
  Future<UserProfile?> fetchUserProfile(String username) async => UserProfile(
    platform: Platform.leetcode,
    handle: username,
    problemsSolved: 3,
    submissionStats: const SubmissionStats(accepted: 4, total: 5),
  );

  @override
  Future<({UserProfile? profile, List<RatingChange> history})> fetchContestInfo(
    String username,
  ) async => (
    profile: UserProfile(
      platform: Platform.leetcode,
      handle: username,
      currentRating: 1700,
    ),
    history: <RatingChange>[],
  );

  @override
  Future<ActivityData?> fetchActivityCalendar(
    String username, {
    int? year,
    DateTime? now,
  }) => pending?.future ?? Future.value(activity);
}

class _Codeforces extends CodeforcesService {
  @override
  Future<UserProfile?> fetchUserInfo(String handle) async =>
      UserProfile(platform: Platform.codeforces, handle: handle);

  @override
  Future<({int solved, SubmissionStats stats, ActivityData activity})?>
  fetchSubmissionSummary(String handle) async => (
    solved: 1,
    stats: const SubmissionStats(accepted: 1, total: 15),
    activity: ActivityData(
      submissionCalendar: {
        DateTime.utc(2026, 10, 15): 3,
        DateTime.utc(2026, 10, 14): 2,
      },
    ),
  );

  @override
  Future<List<RatingChange>> fetchRatingHistory(String handle) async => [];
}

class _CodeChef extends CodeChefService {
  @override
  Future<SubmissionStats?> fetchSubmissionStats(String handle) async =>
      const SubmissionStats(accepted: 3, total: 4);

  @override
  Future<UserProfile?> fetchUserProfile(String handle) async => UserProfile(
    platform: Platform.codechef,
    handle: handle,
    problemsSolved: 44,
    activityData: ActivityData(
      submissionCalendar: {DateTime.utc(2026, 10, 15): 2},
    ),
  );

  @override
  Future<List<RatingChange>> fetchRatingHistory(String handle) async => [];
}

void main() {
  testWidgets(
    'profile displays weighted acceptance with the contributing platforms',
    (tester) async {
      AppTypography.labelSmall = const TextStyle(fontSize: 11);
      AppTypography.labelMedium = const TextStyle(fontSize: 12);
      AppTypography.labelLarge = const TextStyle(fontSize: 14);
      AppTypography.bodySmall = const TextStyle(fontSize: 12);
      AppTypography.displayMedium = const TextStyle(fontSize: 44);
      AppTypography.headlineSmall = const TextStyle(fontSize: 24);
      AppTypography.statLabel = const TextStyle(fontSize: 10);
      AppTypography.statNumberMedium = const TextStyle(fontSize: 32);
      AppTypography.titleLarge = const TextStyle(fontSize: 22);
      final provider = ProfileProvider(
        lcService: _LeetCode(),
        cfService: _Codeforces(),
        ccService: _CodeChef(),
      );
      final settings = SettingsProvider();
      addTearDown(provider.dispose);
      addTearDown(settings.dispose);
      provider.setHandles({
        'leetcode': 'coder',
        'codeforces': 'coder',
        'codechef': 'coder',
      });
      await provider.fetchAllProfiles();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider.value(value: settings),
          ],
          child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('TOTAL SUBMISSIONS'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('33.3%'), findsOneWidget);
      expect(
        find.text('Submission stats: LeetCode, Codeforces, CodeChef'),
        findsOneWidget,
      );
      expect(find.text('24'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'profile merge preserves attempts and aggregate acceptance is weighted',
    () async {
      final provider = ProfileProvider(
        lcService: _LeetCode(),
        cfService: _Codeforces(),
        ccService: _CodeChef(),
      );
      addTearDown(provider.dispose);
      provider.setHandles({
        'leetcode': 'coder',
        'codeforces': 'coder',
        'codechef': 'coder',
      });
      await provider.fetchAllProfiles();
      expect(provider.getProfile(Platform.leetcode)!.currentRating, 1700);
      expect(provider.getProfile(Platform.leetcode)!.submissionStats!.total, 5);
      expect(provider.totalSolved, 48);
      expect(provider.submissionStats!.total, 24);
      expect(provider.submissionStats!.acceptanceRate, closeTo(33.333, 0.001));
      expect(
        provider.activityData!.submissionCalendar[DateTime.utc(2026, 10, 15)],
        6,
      );
      expect(
        provider.activityData!.submissionCalendar[DateTime.utc(2026, 10, 14)],
        2,
      );
      expect(provider.activityData!.totalActiveDays, 2);
      expect(provider.activityPlatforms, unorderedEquals(Platform.values));
      expect(
        provider.submissionProfiles.map((profile) => profile.platform),
        unorderedEquals(Platform.values),
      );
    },
  );

  test('removing a handle clears its activity and submission stats', () async {
    final provider = ProfileProvider(lcService: _LeetCode());
    addTearDown(provider.dispose);
    provider.setHandles({'leetcode': 'old'});
    await provider.fetchAllProfiles();
    expect(provider.activityData, isNotNull);
    provider.setHandles({});
    await provider.fetchAllProfiles();
    expect(provider.activityData, isNull);
    expect(provider.profiles, isEmpty);
    expect(provider.submissionStats, isNull);
  });

  test(
    'a pending response cannot restore the previous account heatmap',
    () async {
      final service = _LeetCode()..pending = Completer<ActivityData?>();
      final provider = ProfileProvider(lcService: service);
      addTearDown(provider.dispose);
      provider.setHandles({'leetcode': 'old'});
      final request = provider.fetchAllProfiles();
      await Future<void>.delayed(Duration.zero);
      provider.setHandles({'leetcode': 'new'});
      service.pending!.complete(service.activity);
      await request;
      expect(provider.activityData, isNull);
      expect(provider.profiles, isEmpty);
    },
  );
}
