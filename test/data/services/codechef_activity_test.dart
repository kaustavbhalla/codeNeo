import 'dart:convert';
import 'package:contest_tracker/data/models/user_profile.dart';
import 'package:contest_tracker/data/services/codechef_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String row(int id, String verdict) =>
    '''<tr><td><span class='tooltips'>some time ago</span></td>
  <td><a href='/problems/TEST'>TEST</a></td>
  <td><span title='$verdict' style='display:flex'>result</span></td>
  <td><a href='/viewsolution/$id'>View</a></td></tr>''';

void main() {
  test(
    'CodeChef extracts all daily activity including unpadded dates',
    () async {
      final client = MockClient(
        (_) async => http.Response('''
      <h3>Total Problems Solved: 44</h3>
      <script>var userDailySubmissionsStats = [
        {"date":"2026-2-24","value":46},
        {"date":"2026-9-22","value":7},
        {"date":"2026-10-14","value":9}];</script>
    ''', 200),
      );
      addTearDown(client.close);
      final profile = await CodeChefService(
        client: client,
      ).fetchUserProfile('coder');
      expect(
        profile!.activityData!.submissionCalendar[DateTime.utc(2026, 2, 24)],
        46,
      );
      expect(
        profile.activityData!.submissionCalendar.values.reduce((a, b) => a + b),
        62,
      );
      expect(profile.problemsSolved, 44);
      final restored = UserProfile.fromJson(profile.toJson());
      expect(
        restored.activityData!.submissionCalendar,
        profile.activityData!.submissionCalendar,
      );
    },
  );

  test(
    'absent CodeChef calendar differs from a successfully loaded empty calendar',
    () async {
      var html = '<h3>Total Problems Solved: 0</h3>';
      final client = MockClient((_) async => http.Response(html, 200));
      addTearDown(client.close);
      final service = CodeChefService(client: client);
      expect((await service.fetchUserProfile('coder'))!.activityData, isNull);
      html += '<script>var userDailySubmissionsStats = [];</script>';
      expect(
        (await service.fetchUserProfile(
          'coder',
        ))!.activityData!.submissionCalendar,
        isEmpty,
      );
    },
  );

  test(
    'CodeChef rates load every public page and deduplicate repeated submissions',
    () async {
      final pages = <int>[];
      final client = MockClient((request) async {
        expect(request.url.path, '/recent/user');
        expect(request.url.queryParameters['user_handle'], 'coder');
        final page = int.parse(request.url.queryParameters['page']!);
        pages.add(page);
        final rows =
            page == 0
                ? row(1, 'accepted') + row(2, 'wrong answer')
                : row(1, 'accepted') +
                    row(3, 'partially accepted') +
                    row(4, 'runtime error(SIGABRT)') +
                    row(5, 'accepted') +
                    row(6, 'queued');
        return http.Response(
          jsonEncode({'max_page': 2, 'content': '<table>$rows</table>'}),
          200,
        );
      });
      addTearDown(client.close);
      final stats = await CodeChefService(
        client: client,
      ).fetchSubmissionStats('coder');
      expect(pages, [0, 1]);
      expect(stats!.total, 5);
      expect(stats.accepted, 2);
      expect(stats.acceptanceRate, 40);
    },
  );

  test(
    'a failed later CodeChef page never produces a partial acceptance rate',
    () async {
      final client = MockClient(
        (request) async =>
            request.url.queryParameters['page'] == '0'
                ? http.Response(
                  jsonEncode({
                    'max_page': 2,
                    'content': '<table>${row(1, 'accepted')}</table>',
                  }),
                  200,
                )
                : http.Response('blocked', 403),
      );
      addTearDown(client.close);
      expect(
        await CodeChefService(client: client).fetchSubmissionStats('coder'),
        isNull,
      );
    },
  );

  test(
    'unrecognized CodeChef verdicts are unavailable rather than accepted or rejected',
    () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'max_page': 1,
            'content': '<table>${row(1, 'unknown status')}</table>',
          }),
          200,
        ),
      );
      addTearDown(client.close);
      expect(
        await CodeChefService(client: client).fetchSubmissionStats('coder'),
        isNull,
      );
    },
  );

  test(
    'an empty public CodeChef submission list has no defined acceptance rate',
    () async {
      final client = MockClient(
        (_) async =>
            http.Response('{"max_page":0,"content":"<table></table>"}', 200),
      );
      addTearDown(client.close);
      final stats = await CodeChefService(
        client: client,
      ).fetchSubmissionStats('coder');
      expect(stats!.total, 0);
      expect(stats.acceptanceRate, isNull);
    },
  );
}
