import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/platform_utils.dart';
import '../../data/models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/platform_widgets.dart';
import '../../widgets/activity_heatmap.dart';

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
                            'TOTAL SOLVED ACROSS CONNECTED PLATFORMS',
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
                    ActivityHeatmap(
                      activityData: profileProv.activityData,
                      platforms: profileProv.activityPlatforms,
                      missingPlatforms: profileProv.missingActivityPlatforms,
                    ),

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
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
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

  void _showSettingsDialog(
    BuildContext context,
    SettingsProvider settingsProv,
  ) {
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
      builder:
          (ctx) => AlertDialog(
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
              style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
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
                      Text('RATING', style: AppTypography.statLabel),
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
                      Text('SOLVED', style: AppTypography.statLabel),
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
                      Text('CONTESTS', style: AppTypography.statLabel),
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
            ),
          if (profile != null) ...[
            const SizedBox(height: 12),
            _StatBox(
              label: 'ACCEPTANCE RATE',
              value:
                  profile!.submissionStats?.acceptanceRate == null
                      ? '—'
                      : '${profile!.submissionStats!.acceptanceRate!.toStringAsFixed(1)}%',
            ),
            if (profile!.submissionStats == null)
              Text(
                'Submission totals unavailable',
                style: AppTypography.bodySmall,
              ),
            if (platform == Platform.codechef &&
                profile!.submissionStats != null)
              Text(
                'Based on publicly listed submissions; learning-path attempts may be omitted.',
                style: AppTypography.bodySmall,
              ),
          ] else
            Text(
              handle == null || handle!.isEmpty
                  ? 'No handle configured'
                  : 'Loading...',
              style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
            ),
        ],
      ),
    );
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
                  value: profileProv.submissionStats?.total.toString() ?? '—',
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'ACCEPTANCE RATE',
                  value:
                      profileProv.submissionStats?.acceptanceRate == null
                          ? '—'
                          : '${profileProv.submissionStats!.acceptanceRate!.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profileProv.submissionProfiles.isEmpty
                ? 'Submission statistics unavailable'
                : 'Submission stats: ${profileProv.submissionProfiles.map((profile) => profile.platform.displayName).join(', ')}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          if (profileProv.submissionProfiles.any(
            (profile) => profile.platform == Platform.codechef,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'CodeChef acceptance covers publicly listed submissions; learning-path attempts may be omitted.',
                style: AppTypography.bodySmall,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'CURRENT ACTIVITY STREAK',
                  value:
                      profileProv.activityData?.currentStreak.toString() ?? '—',
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
        Text(label, style: AppTypography.statLabel),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
