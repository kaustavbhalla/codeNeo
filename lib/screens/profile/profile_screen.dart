import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/platform_utils.dart';
import '../../data/models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/platform_widgets.dart';

/// Global Profile screen — aggregate stats, heatmap, platform cards.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, SettingsProvider>(
      builder: (context, profileProv, settingsProv, _) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainer,
          onRefresh: () => profileProv.fetchAllProfiles(),
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SYSTEM.CORE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'PROFILE_MATRIX',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    onPressed: () => _showSettingsDialog(context, settingsProv),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Hero section
                    SurfaceCard(
                      color: AppColors.surfaceContainerHigh,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INTEGRATED DSA_PILOT',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${profileProv.totalSolved} SOLVED',
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 48,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GLOBAL DISTRIBUTION INDEX | LAST 180 DAYS',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Avatar
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.headphones,
                              color: AppColors.outline,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CP_PLAYER',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Activity Heatmap
                    _ActivityHeatmap(activityData: profileProv.activityData),

                    const SizedBox(height: 16),

                    // Platform cards
                    ...Platform.values.map((platform) {
                      final profile = profileProv.getProfile(platform);
                      final handle = settingsProv.handles[platform.name];
                      return _PlatformProfileCard(
                        platform: platform,
                        profile: profile,
                        handle: handle,
                      );
                    }),

                    const SizedBox(height: 16),

                    // Aggregate stats
                    _AggregateStats(profileProv: profileProv),

                    const SizedBox(height: 16),

                    // Refresh button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => profileProv.fetchAllProfiles(),
                        icon: const Icon(Icons.sync, size: 16),
                        label: Text(
                          'REFRESH DATA',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context, SettingsProvider settingsProv) {
    final lcController = TextEditingController(
      text: settingsProv.handles['leetcode'] ?? '',
    );
    final cfController = TextEditingController(
      text: settingsProv.handles['codeforces'] ?? '',
    );
    final ccController = TextEditingController(
      text: settingsProv.handles['codechef'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'CONFIGURE HANDLES',
          style: AppTypography.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lcController,
              decoration: const InputDecoration(
                labelText: 'LeetCode',
                prefixText: 'LC: ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cfController,
              decoration: const InputDecoration(
                labelText: 'Codeforces',
                prefixText: 'CF: ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ccController,
              decoration: const InputDecoration(
                labelText: 'CodeChef',
                prefixText: 'CC: ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final handles = <String, String>{};
              if (lcController.text.trim().isNotEmpty) {
                handles['leetcode'] = lcController.text.trim();
              }
              if (cfController.text.trim().isNotEmpty) {
                handles['codeforces'] = cfController.text.trim();
              }
              if (ccController.text.trim().isNotEmpty) {
                handles['codechef'] = ccController.text.trim();
              }
              settingsProv.saveHandles(handles);

              final profileProv = context.read<ProfileProvider>();
              profileProv.setHandles(handles);
              profileProv.fetchAllProfiles();

              Navigator.pop(ctx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

/// GitHub-style activity heatmap.
class _ActivityHeatmap extends StatelessWidget {
  final ActivityData? activityData;

  const _ActivityHeatmap({this.activityData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weeksToShow = 20;
    final startDate = now.subtract(Duration(days: weeksToShow * 7));

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ACTIVITY',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const Spacer(),
              Text(
                'LEETCODE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CODEFORCES',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CODECHEF',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Heatmap grid
          SizedBox(
            height: 96,
            child: Row(
              children: List.generate(weeksToShow, (weekIndex) {
                return Expanded(
                  child: Column(
                    children: List.generate(7, (dayIndex) {
                      final date = startDate.add(
                        Duration(days: weekIndex * 7 + dayIndex),
                      );
                      final normalizedDate = DateTime.utc(
                        date.year,
                        date.month,
                        date.day,
                      );
                      final count =
                          activityData?.submissionCalendar[normalizedDate] ?? 0;

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: _getHeatColor(count),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Streak info
          Row(
            children: [
              Text(
                '${activityData?.currentStreak ?? 0} DAY STREAK',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${activityData?.totalActiveDays ?? 0}',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'DAYS',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(width: 16),
              // Intensity legend
              ...List.generate(4, (i) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: _getHeatColor((i + 1) * 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHeatColor(int count) {
    if (count == 0) return AppColors.surfaceContainerLow;
    if (count <= 1) return AppColors.primary.withValues(alpha: 0.15);
    if (count <= 3) return AppColors.primary.withValues(alpha: 0.30);
    if (count <= 5) return AppColors.primary.withValues(alpha: 0.50);
    return AppColors.primary.withValues(alpha: 0.75);
  }
}

/// Per-platform profile card.
class _PlatformProfileCard extends StatelessWidget {
  final Platform platform;
  final UserProfile? profile;
  final String? handle;

  const _PlatformProfileCard({
    required this.platform,
    this.profile,
    this.handle,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformBadge(platform: platform, size: 32),
              const Spacer(),
              if (handle != null && handle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'CONNECT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            platform.displayName.toUpperCase(),
            style: AppTypography.headlineSmall,
          ),
          if (handle != null && handle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '@${handle!}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.outline,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (profile != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RATING',
                        style: AppTypography.statLabel,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile!.currentRating}',
                        style: AppTypography.statNumberMedium.copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOLVED',
                        style: AppTypography.statLabel,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile!.problemsSolved}',
                        style: AppTypography.statNumberMedium.copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTESTS',
                        style: AppTypography.statLabel,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile!.contestsAttended}',
                        style: AppTypography.statNumberMedium.copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              handle == null || handle!.isEmpty
                  ? 'No handle configured'
                  : 'Loading...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.outline,
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

/// Aggregate stats row.
class _AggregateStats extends StatelessWidget {
  final ProfileProvider profileProv;

  const _AggregateStats({required this.profileProv});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'TOTAL SUBMISSIONS',
                  value: '${profileProv.totalSolved}',
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'ACCEPTANCE RATE',
                  value: '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'DAYS STREAKED',
                  value: '${profileProv.activityData?.currentStreak ?? 0}',
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'TOTAL COMPETITIONS',
                  value: '${profileProv.totalContests}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.statLabel,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
