import 'package:contest_tracker/core/theme/app_typography.dart';
import 'package:contest_tracker/data/models/user_profile.dart';
import 'package:contest_tracker/widgets/activity_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    // Use system fonts in widget tests without downloading Google Fonts.
    AppTypography.labelSmall = const TextStyle(fontSize: 11);
    AppTypography.labelMedium = const TextStyle(fontSize: 12);
    AppTypography.bodySmall = const TextStyle(fontSize: 12);
  });

  testWidgets(
    '180 dated cells include today, align weekdays and fit narrow screens',
    (tester) async {
      final today = DateTime.utc(
        2026,
        1,
        3,
      ); // Saturday, across a year boundary.
      final start = today.subtract(const Duration(days: 179));
      final activity = ActivityData(
        submissionCalendar: {
          today: 4,
          today.subtract(const Duration(days: 1)): 1,
          start.subtract(const Duration(days: 1)): 7,
        },
        longestStreak: 99,
        totalActiveDays: 99,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 280,
                child: ActivityHeatmap(activityData: activity, now: today),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Tooltip), findsNWidgets(180));
      expect(find.byKey(ValueKey(today)), findsOneWidget);
      expect(find.byKey(ValueKey(start)), findsOneWidget);
      expect(
        find.byKey(ValueKey(start.subtract(const Duration(days: 1)))),
        findsNothing,
      );
      expect(find.text('2 DAY CURRENT STREAK'), findsOneWidget);
      expect(find.text('2 ACTIVE DAYS'), findsOneWidget);
      expect(
        find.textContaining('Submissions · last 180 days'),
        findsOneWidget,
      );
      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
      expect(
        tooltips.any(
          (tooltip) => tooltip.message == 'Jan 3, 2026: 4 submissions',
        ),
        isTrue,
      );
      // Every Sunday has the same vertical position; Saturday is six rows below it.
      final sunday = DateTime.utc(2025, 12, 28);
      expect(
        tester.getTopLeft(find.byKey(ValueKey(today))).dy -
            tester.getTopLeft(find.byKey(ValueKey(sunday))).dy,
        72,
      );
    },
  );

  testWidgets('unavailable activity is not rendered as zero submissions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ActivityHeatmap())),
    );
    expect(find.textContaining('Activity unavailable'), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
    expect(find.text('0 DAY CURRENT STREAK'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
