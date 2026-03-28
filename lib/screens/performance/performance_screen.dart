import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/platform_utils.dart';
import '../../data/models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/platform_widgets.dart';

/// Performance Terminal screen — rating charts and contest history.
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainer,
          onRefresh: () => provider.fetchAllProfiles(),
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
                      'RANKINGS',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => provider.fetchAllProfiles(),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'PERFORMANCE\nTERMINAL',
                      style: AppTypography.displaySmall,
                    ),

                    const SizedBox(height: 24),

                    if (provider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else ...[
                      // Rating cards for each platform
                      ...Platform.values.map((platform) {
                        final profile = provider.getProfile(platform);
                        final history = provider.getRatingHistory(platform);
                        if (profile == null && history.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _RatingCard(
                          platform: platform,
                          profile: profile,
                          history: history,
                        );
                      }),

                      const SizedBox(height: 32),

                      // Recent Engagement
                      Text(
                        'RECENT\nENGAGEMENT',
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CONTEST_LOG_LATEST',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ..._getRecentContests(provider).map(
                        (r) => _RecentContestItem(ratingChange: r),
                      ),

                      const SizedBox(height: 32),

                      // Consistency Score
                      SurfaceCard(
                        color: AppColors.surfaceContainerLow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.insights,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CONSISTENCY SCORE',
                                  style: AppTypography.labelLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Track your regularity across platforms. Compete in more contests to improve your consistency rating.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${provider.totalContests}',
                                  style: AppTypography.statNumberMedium,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'TOTAL CONTESTS',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

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

  List<RatingChange> _getRecentContests(ProfileProvider provider) {
    final all = <RatingChange>[];
    for (final platform in Platform.values) {
      all.addAll(provider.getRatingHistory(platform));
    }
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all.take(8).toList();
  }
}

/// Rating card with line chart for a single platform.
class _RatingCard extends StatelessWidget {
  final Platform platform;
  final UserProfile? profile;
  final List<RatingChange> history;

  const _RatingCard({
    required this.platform,
    this.profile,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformBadge(platform: platform, size: 28),
              const Spacer(),
              if (profile != null)
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
                    profile!.rank,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${profile?.currentRating ?? 0}',
            style: AppTypography.statNumber.copyWith(fontSize: 40),
          ),
          const SizedBox(height: 4),
          Text(
            platform.displayName.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.outline,
            ),
          ),

          // Chart
          if (history.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: _buildChart(),
            ),
          ],

          const SizedBox(height: 12),

          // Stats row
          if (profile != null)
            Row(
              children: [
                _StatItem(
                  label: 'MAX RATING',
                  value: '${profile!.maxRating}',
                ),
                const SizedBox(width: 24),
                _StatItem(
                  label: 'CONTESTS',
                  value: '${profile!.contestsAttended}',
                ),
                if (profile!.globalRank > 0) ...[
                  const SizedBox(width: 24),
                  _StatItem(
                    label: 'GLOBAL RANK',
                    value: '#${_formatNumber(profile!.globalRank)}',
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].newRating.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.surfaceContainerHighest,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                if (index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primary,
                    strokeWidth: 0,
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.05),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.statLabel,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RecentContestItem extends StatelessWidget {
  final RatingChange ratingChange;

  const _RecentContestItem({required this.ratingChange});

  @override
  Widget build(BuildContext context) {
    final isPositive = ratingChange.isPositive;

    return SurfaceCard(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          PlatformBadge(platform: ratingChange.platform, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ratingChange.contestName.toUpperCase(),
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppDateUtils.formatDate(ratingChange.timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#${ratingChange.rank}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${isPositive ? '+' : ''}${ratingChange.ratingChange}',
                style: AppTypography.titleSmall.copyWith(
                  color: isPositive
                      ? AppColors.ratingUp
                      : AppColors.ratingDown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
