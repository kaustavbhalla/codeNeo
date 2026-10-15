import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/models/user_profile.dart';
import '../core/utils/platform_utils.dart';
import 'platform_widgets.dart';

/// Combined daily submission activity, preserving each platform's bucket dates.
class ActivityHeatmap extends StatelessWidget {
  final ActivityData? activityData;
  final DateTime? now;
  final List<Platform> platforms;
  final List<Platform> missingPlatforms;

  const ActivityHeatmap({
    super.key,
    this.activityData,
    this.now,
    this.platforms = const [],
    this.missingPlatforms = const [],
  });

  @override
  Widget build(BuildContext context) {
    final today = ActivityData.day(now ?? DateTime.now());
    final start = today.subtract(const Duration(days: 179));
    final gridStart = start.subtract(Duration(days: start.weekday % 7));
    final weeks = (today.difference(gridStart).inDays + 1 + 6) ~/ 7;
    final activity = activityData;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMBINED ACTIVITY', style: AppTypography.labelMedium),
          if (platforms.isNotEmpty)
            Text(
              platforms.map((platform) => platform.displayName).join(' · '),
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: 4),
          Text('Submissions · last 180 days', style: AppTypography.bodySmall),
          Text(
            'Dates follow each platform’s calendar.',
            style: AppTypography.bodySmall,
          ),
          if (missingPlatforms.isNotEmpty)
            Text(
              'Activity unavailable: ${missingPlatforms.map((platform) => platform.displayName).join(', ')}',
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat.yMMMd().format(start)} – ${DateFormat.yMMMd().format(today)}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 16),
          if (activity == null)
            Text(
              'Activity unavailable. Add a handle or refresh your profile.',
              style: AppTypography.bodySmall,
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 18),
                      for (final label in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                        SizedBox(
                          height: 12,
                          width: 18,
                          child: Text(
                            label,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (var week = 0; week < weeks; week++)
                    _week(
                      gridStart.add(Duration(days: week * 7)),
                      start,
                      today,
                      activity,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  '${activity.currentStreakAt(today)} DAY CURRENT STREAK',
                  style: AppTypography.labelSmall,
                ),
                Text(
                  '${activity.activeDaysBetween(start, today)} ACTIVE DAYS',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Less', style: AppTypography.bodySmall),
                const SizedBox(width: 6),
                for (final count in [0, 1, 2, 4, 6])
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 2),
                    color: _heatColor(count),
                  ),
                const SizedBox(width: 4),
                Text('More', style: AppTypography.bodySmall),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _week(
    DateTime weekStart,
    DateTime start,
    DateTime today,
    ActivityData activity,
  ) {
    // Reserve the same height for every month label so weekday rows stay aligned.
    final dates = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );
    final monthStart = dates.where(
      (date) => date.day == 1 && !date.isAfter(today),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 18,
          width: 12,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: 32,
            child: Text(
              monthStart.isEmpty
                  ? ''
                  : DateFormat.MMM().format(monthStart.first),
              style: AppTypography.labelSmall.copyWith(fontSize: 8),
            ),
          ),
        ),
        for (final date in dates)
          if (date.isBefore(start) || date.isAfter(today))
            const SizedBox(width: 12, height: 12)
          else
            Tooltip(
              message:
                  '${DateFormat.yMMMd().format(date)}: ${activity.submissionCalendar[date] ?? 0} submissions',
              child: Container(
                key: ValueKey(date),
                width: 11,
                height: 11,
                margin: const EdgeInsets.only(right: 1, bottom: 1),
                decoration: BoxDecoration(
                  color: _heatColor(activity.submissionCalendar[date] ?? 0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
      ],
    );
  }

  Color _heatColor(int count) {
    if (count <= 0) return AppColors.surfaceContainerLow;
    if (count == 1) return AppColors.primary.withValues(alpha: 0.15);
    if (count <= 3) return AppColors.primary.withValues(alpha: 0.30);
    if (count <= 5) return AppColors.primary.withValues(alpha: 0.50);
    return AppColors.primary.withValues(alpha: 0.75);
  }
}
