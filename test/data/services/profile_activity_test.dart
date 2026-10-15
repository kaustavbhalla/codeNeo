import 'dart:convert';
import 'package:contest_tracker/data/models/user_profile.dart';
import 'package:contest_tracker/data/services/codeforces_service.dart';
import 'package:contest_tracker/data/services/leetcode_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'LeetCode acceptance uses attempt totals rather than unique problems',
    () async {
      final client = MockClient((request) async {
        final query = jsonDecode(request.body)['query'] as String;
        expect(query, contains('totalSubmissionNum'));
        expect(query, contains('submissions'));
        return http.Response(
          jsonEncode({
            'data': {
              'matchedUser': {
                'submitStatsGlobal': {
                  'acSubmissionNum': [
                    {'difficulty': 'All', 'count': 33, 'submissions': 41},
                  ],
                  'totalSubmissionNum': [
                    {'difficulty': 'All', 'count': 34, 'submissions': 51},
                  ],
                },
              },
            },
          }),
          200,
        );
      });
      addTearDown(client.close);
      final profile = await LeetCodeService(
        client: client,
      ).fetchUserProfile('coder');
      expect(profile!.problemsSolved, 33);
      expect(profile.submissionStats!.total, 51);
      expect(profile.submissionStats!.acceptanceRate, closeTo(80.392, 0.001));
      final restored = UserProfile.fromJson(profile.toJson());
      expect(
        restored.copyWith(currentRating: 1800).submissionStats!.accepted,
        41,
      );
    },
  );

  test(
    'unavailable attempt totals do not turn unique counts into a rate',
    () async {
      final client = MockClient(
        (_) async => http.Response(
          '{"data":{"matchedUser":{"submitStatsGlobal":{"acSubmissionNum":[{"difficulty":"All","count":3}]}}}}',
          200,
        ),
      );
      addTearDown(client.close);
      final profile = await LeetCodeService(
        client: client,
      ).fetchUserProfile('coder');
      expect(profile!.submissionStats, isNull);
      expect(
        const SubmissionStats(accepted: 0, total: 0).acceptanceRate,
        isNull,
      );
      expect(const SubmissionStats(accepted: 0, total: 10).acceptanceRate, 0);
    },
  );

  test(
    'calendar loads both years across January and sums same-day entries in UTC',
    () async {
      final years = <int>[];
      final first = DateTime.utc(2025, 12, 31).millisecondsSinceEpoch ~/ 1000;
      final second = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
      final client = MockClient((request) async {
        final year = jsonDecode(request.body)['variables']['year'] as int;
        years.add(year);
        final calendar =
            year == 2025
                ? {'$first': 2}
                : {'$second': 1, '${second + 3600}': 3, 'invalid': 5};
        return http.Response(
          jsonEncode({
            'data': {
              'matchedUser': {
                'userCalendar': {
                  'submissionCalendar': jsonEncode(calendar),
                  'streak': 12,
                  'activeYears': [2025, 2026],
                  'totalActiveDays': 99,
                },
              },
            },
          }),
          200,
        );
      });
      addTearDown(client.close);
      final activity = await LeetCodeService(
        client: client,
      ).fetchActivityCalendar('coder', now: DateTime.utc(2026, 1, 1));
      expect(years, unorderedEquals([2025, 2026]));
      expect(activity!.submissionCalendar[DateTime.utc(2026, 1, 1)], 4);
      expect(activity.currentStreakAt(DateTime.utc(2026, 1, 1)), 2);
      expect(activity.longestStreak, 12);
      expect(activity.totalActiveDays, 2);
      expect(
        activity.activeDaysBetween(
          DateTime.utc(2026),
          DateTime.utc(2026, 1, 2),
        ),
        1,
      );
    },
  );

  test(
    'failed calendar year is unavailable rather than a partial empty heatmap',
    () async {
      final client = MockClient((_) async => http.Response('unavailable', 503));
      addTearDown(client.close);
      expect(
        await LeetCodeService(client: client).fetchActivityCalendar('coder'),
        isNull,
      );
    },
  );

  test('current streak allows yesterday but not older activity', () {
    final activity = ActivityData(
      submissionCalendar: {
        DateTime.utc(2026, 10, 13): 3,
        DateTime.utc(2026, 10, 14): 1,
      },
      longestStreak: 20,
    );
    expect(activity.currentStreakAt(DateTime.utc(2026, 10, 15)), 2);
    expect(activity.currentStreakAt(DateTime.utc(2026, 10, 16)), 0);
    expect(
      ActivityData.day(DateTime.parse('2026-10-15T02:00:00+05:30')),
      DateTime.utc(2026, 10, 14),
    );
  });

  test(
    'Codeforces distinguishes distinct solves and accepted attempts',
    () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 'OK',
            'result': [
              for (final verdict in [
                'OK',
                'OK',
                'WRONG_ANSWER',
                'COMPILATION_ERROR',
                'TESTING',
                'SKIPPED',
                null,
              ])
                {
                  'verdict': verdict,
                  'creationTimeSeconds':
                      DateTime.utc(2026, 10, 15, 23).millisecondsSinceEpoch ~/
                      1000,
                  'problem': {'contestId': 1, 'index': 'A'},
                },
            ],
          }),
          200,
        ),
      );
      addTearDown(client.close);
      final summary = await CodeforcesService(
        client: client,
      ).fetchSubmissionSummary('coder');
      expect(summary!.solved, 1);
      expect(summary.stats.accepted, 2);
      expect(summary.stats.total, 4);
      expect(summary.stats.acceptanceRate, 50);
      expect(
        summary.activity.submissionCalendar[DateTime.utc(2026, 10, 15)],
        7,
      );
    },
  );

  test(
    'failed Codeforces request is unavailable rather than zero attempts',
    () async {
      final client = MockClient(
        (_) async => http.Response('{"status":"FAILED"}', 200),
      );
      addTearDown(client.close);
      expect(
        await CodeforcesService(client: client).fetchSubmissionSummary('coder'),
        isNull,
      );
    },
  );
}
