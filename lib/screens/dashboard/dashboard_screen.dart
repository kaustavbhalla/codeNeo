import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/platform_utils.dart';
import '../../data/models/contest.dart';
import '../../providers/contest_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/platform_widgets.dart';
import '../../widgets/nothing_toggle.dart';

/// Main contest dashboard screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Start countdown timer AFTER the first frame to avoid
    // setState() during the initial build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _countdownTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) {
            if (mounted) setState(() {});
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContestProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainer,
          onRefresh: () => provider.fetchContests(),
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
                      'DASHBOARD',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => provider.fetchContests(),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Status bar
                    Row(
                      children: [
                        Text(
                          'LIVE_FEED_ACTIVE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${provider.totalUpcoming} UPCOMING',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Hero contest card
                    if (provider.nextContest != null)
                      _HeroContestCard(contest: provider.nextContest!),

                    const SizedBox(height: 32),

                    // Section header
                    Text(
                      'UPCOMING SEQUENCE',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CHRONOLOGICAL_VIEW_${provider.upcomingContests.length.toString().padLeft(2, '0')}_ITEMS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.outline,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Platform filters
                    PlatformFilterChips(
                      selectedPlatform: provider.filterPlatform,
                      onSelected: (p) => provider.setFilter(p),
                    ),

                    const SizedBox(height: 20),

                    // Contest list
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
                    else if (provider.upcomingContests.isEmpty)
                      _EmptyState()
                    else
                      ...provider.upcomingContests.map(
                        (c) => _ContestListItem(contest: c),
                      ),

                    // Past contests header
                    if (provider.pastContests.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        'PAST ENGAGEMENTS',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...provider.pastContests.take(5).map(
                            (c) => _ContestListItem(
                              contest: c,
                              isPast: true,
                            ),
                          ),
                    ],

                    const SizedBox(height: 16),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'LIVE DATA ESTABLISHED',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All timestamps are normalized to UTC with local conversion. Data provided by official platform APIs.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'VERS. 2.0.4',
                        style: AppTypography.versionText,
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
}

/// Hero card for the next upcoming contest.
class _HeroContestCard extends StatelessWidget {
  final Contest contest;

  const _HeroContestCard({required this.contest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformBadge(platform: contest.platform, size: 28),
              const SizedBox(width: 8),
              Text(
                contest.platform.displayName.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: contest.isRunning
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  contest.isRunning ? 'LIVE' : 'NEXT',
                  style: AppTypography.labelSmall.copyWith(
                    color: contest.isRunning
                        ? AppColors.success
                        : AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            contest.name.toUpperCase(),
            style: AppTypography.headlineLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'STARTS AT',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppDateUtils.formatUtc(contest.startTime),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'UTC',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'LOCAL: ${AppDateUtils.formatLocal(contest.startTime)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Countdown
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  AppDateUtils.countdown(contest.startTime),
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CTA buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openContest(contest),
                  child: Text(
                    'REGISTER NOW',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () => _openContest(contest),
                  icon: const Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openContest(Contest contest) async {
    if (contest.url != null) {
      final uri = Uri.parse(contest.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

/// Individual contest list item.
class _ContestListItem extends StatelessWidget {
  final Contest contest;
  final bool isPast;

  const _ContestListItem({
    required this.contest,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: isPast
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainer,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformBadge(platform: contest.platform, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contest.platform.displayName.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.outline,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contest.name.toUpperCase(),
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      AppDateUtils.formatUtc(contest.startTime),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'UTC',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.outlineVariant,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppDateUtils.formatDuration(contest.duration),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isPast)
            Consumer2<ContestProvider, SettingsProvider>(
              builder: (_, contestProv, settingsProv, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppDateUtils.countdown(contest.startTime),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    NothingToggle(
                      value: contest.notificationsEnabled,
                      onChanged: (_) {
                        contestProv.toggleContestNotification(
                          contest,
                          settingsProv.settings,
                        );
                      },
                      width: 44,
                      height: 24,
                    ),
                  ],
                );
              },
            )
          else
            Text(
              AppDateUtils.relativeTime(contest.startTime),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.outline,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'NO UPCOMING CONTESTS',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh contest data from all platforms.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.outlineVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
