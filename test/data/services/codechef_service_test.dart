import 'package:contest_tracker/data/services/codechef_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CodeChef solved problems', () {
    Future<int?> fetchSolved(String html) async {
      final client = MockClient((request) async {
        expect(request.url.path, '/users/sunjeetkajla');
        return http.Response(html, 200);
      });
      addTearDown(client.close);
      final profile = await CodeChefService(
        client: client,
      ).fetchUserProfile('sunjeetkajla');
      expect(profile, isNotNull);
      return profile!.problemsSolved;
    }

    test(
      'reads the profile total independently of path and contest counts',
      () async {
        // Relevant headings from sunjeetkajla's public profile.
        expect(
          await fetchSolved('''
        <section class="rating-data-section problems-solved">
          <h3>Learning Paths (0)</h3>
          <h3>Practice Paths (3)</h3>
          <h3>Contests (1)</h3>
          <h3>Total Problems Solved: 44</h3>
        </section>
      '''),
          44,
        );
      },
    );

    test('handles formatting and thousands separators', () async {
      expect(
        await fetchSolved('''
        <h3>Total&nbsp;Problems\nSolved: <strong>1,234</strong></h3>
      '''),
        1234,
      );
    });

    test('preserves a genuine zero total', () async {
      expect(await fetchSolved('<h3>Total Problems Solved: 0</h3>'), 0);
    });

    test('does not use other counts when the total is unavailable', () async {
      expect(await fetchSolved('<h3>Contests (12)</h3>'), 0);
    });
  });
}
