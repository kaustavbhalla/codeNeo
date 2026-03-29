import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/contest_provider.dart';
import '../../widgets/nothing_toggle.dart';
import '../../widgets/platform_widgets.dart';
import '../../data/services/notification_service.dart';

/// Alerts Config screen — notification timing and platform toggles.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ContestProvider>(
      builder: (context, settingsProv, contestProv, _) {
        final settings = settingsProv.settings;

        return CustomScrollView(
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
                    'NOTIFS',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    'ALERTS\nCONFIG',
                    style: AppTypography.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SYSTEM NOTIFICATION ENGINE  V.2.5.2',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.outline,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Destination Protocols
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESTINATION PROTOCOLS',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProtocolChip(
                          icon: Icons.notifications_outlined,
                          label: 'PUSH',
                          isActive: true,
                        ),
                        const SizedBox(height: 8),
                        _ProtocolChip(
                          icon: Icons.email_outlined,
                          label: 'EMAIL',
                          isActive: false,
                        ),
                        const SizedBox(height: 8),
                        _ProtocolChip(
                          icon: Icons.sms_outlined,
                          label: 'SMS',
                          isActive: false,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Only PUSH channel is active for contest alerts. Email & SMS coming in future updates.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Master Status
                  SurfaceCard(
                    color: settings.masterEnabled
                        ? AppColors.surfaceContainerHigh
                        : AppColors.surfaceContainerLow,
                    child: Column(
                      children: [
                        Icon(
                          settings.masterEnabled
                              ? Icons.sensors
                              : Icons.sensors_off,
                          color: settings.masterEnabled
                              ? AppColors.primary
                              : AppColors.outline,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'STATUS',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.masterEnabled ? 'ACTIVE' : 'INACTIVE',
                          style: AppTypography.headlineMedium.copyWith(
                            color: settings.masterEnabled
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        NothingToggle(
                          value: settings.masterEnabled,
                          onChanged: (val) async {
                            settingsProv.updateSetting((s) {
                              s.masterEnabled = val;
                            });
                            
                            // Ask for notification permissions if the user is turning them on
                            if (val) {
                              await NotificationService().requestPermissions();
                            }
                            
                            contestProv.rescheduleNotifications(
                              settingsProv.settings,
                            );
                          },
                          width: 60,
                          height: 32,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timing section header
                  Row(
                    children: [
                      Text(
                        'ALERT TIMING',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'REMINDER BAND M',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Timing toggles
                  _TimingToggle(
                    title: '1 DAY PRIOR',
                    subtitle: 'Intelligence gathering',
                    value: settings.dayBefore,
                    enabled: settings.masterEnabled,
                    onChanged: (val) {
                      settingsProv.updateSetting((s) => s.dayBefore = val);
                      contestProv.rescheduleNotifications(
                        settingsProv.settings,
                      );
                    },
                  ),
                  _TimingToggle(
                    title: '12 HOURS PRIOR',
                    subtitle: 'System checkpoint',
                    value: settings.twelveHours,
                    enabled: settings.masterEnabled,
                    onChanged: (val) {
                      settingsProv.updateSetting((s) => s.twelveHours = val);
                      contestProv.rescheduleNotifications(
                        settingsProv.settings,
                      );
                    },
                  ),
                  _TimingToggle(
                    title: '5 HOURS PRIOR',
                    subtitle: 'Combat readiness',
                    value: settings.fiveHours,
                    enabled: settings.masterEnabled,
                    onChanged: (val) {
                      settingsProv.updateSetting((s) => s.fiveHours = val);
                      contestProv.rescheduleNotifications(
                        settingsProv.settings,
                      );
                    },
                  ),
                  _TimingToggle(
                    title: '1 HOUR PRIOR',
                    subtitle: 'Deployment ready',
                    value: settings.oneHour,
                    enabled: settings.masterEnabled,
                    onChanged: (val) {
                      settingsProv.updateSetting((s) => s.oneHour = val);
                      contestProv.rescheduleNotifications(
                        settingsProv.settings,
                      );
                    },
                  ),
                  _TimingToggle(
                    title: '30 MINS PRIOR',
                    subtitle: 'Going into protocol',
                    value: settings.thirtyMinutes,
                    enabled: settings.masterEnabled,
                    onChanged: (val) {
                      settingsProv.updateSetting((s) => s.thirtyMinutes = val);
                      contestProv.rescheduleNotifications(
                        settingsProv.settings,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Contest started (special style)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CONTEST STARTED',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Immediate presence is required',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NothingToggle(
                          value: settings.contestStart,
                          onChanged: settings.masterEnabled
                              ? (val) {
                                  settingsProv.updateSetting(
                                    (s) => s.contestStart = val,
                                  );
                                  contestProv.rescheduleNotifications(
                                    settingsProv.settings,
                                  );
                                }
                              : (_) {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Platform priority
                  Text(
                    'PLATFORM PRIORITY',
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ENABLE_ALERTS_PER_PLATFORM',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _PlatformToggleChip(
                          label: 'LEETCODE',
                          shortCode: 'LC',
                          isActive: settings.leetcodeEnabled,
                          color: AppColors.leetcodeAccent,
                          onTap: () {
                            settingsProv.updateSetting((s) {
                              s.leetcodeEnabled = !s.leetcodeEnabled;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PlatformToggleChip(
                          label: 'CODEFORCES',
                          shortCode: 'CF',
                          isActive: settings.codeforcesEnabled,
                          color: AppColors.codeforcesAccent,
                          onTap: () {
                            settingsProv.updateSetting((s) {
                              s.codeforcesEnabled = !s.codeforcesEnabled;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _PlatformToggleChip(
                          label: 'CODECHEF',
                          shortCode: 'CC',
                          isActive: settings.codechefEnabled,
                          color: AppColors.codechefAccent,
                          onTap: () {
                            settingsProv.updateSetting((s) {
                              s.codechefEnabled = !s.codechefEnabled;
                            });
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Test Notification Button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notification scheduled in 5 seconds... go to home screen!'),
                            backgroundColor: AppColors.surfaceContainerHigh,
                          ),
                        );
                        await NotificationService().testNotification();
                      },
                      icon: const Icon(Icons.bug_report_outlined),
                      label: const Text('SEND TEST NOTIFICATION'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProtocolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _ProtocolChip({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.surfaceContainerHighest
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? AppColors.primary : AppColors.outline),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimingToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _TimingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppColors.onSurface
                        : AppColors.outline,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          NothingToggle(
            value: value && enabled,
            onChanged: enabled ? onChanged : (_) {},
          ),
        ],
      ),
    );
  }
}

class _PlatformToggleChip extends StatelessWidget {
  final String label;
  final String shortCode;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _PlatformToggleChip({
    required this.label,
    required this.shortCode,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.surfaceContainerHigh
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                _getLogoPath(),
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isActive ? AppColors.onSurface : AppColors.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLogoPath() {
    switch (shortCode) {
      case 'LC':
        return 'assets/logos/leetcodelogo.png';
      case 'CF':
        return 'assets/logos/code-forces.png';
      case 'CC':
        return 'assets/logos/codecheflogo.png';
      default:
        return 'assets/logos/leetcodelogo.png';
    }
  }
}
