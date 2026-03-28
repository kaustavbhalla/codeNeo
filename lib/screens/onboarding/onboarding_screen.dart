import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/contest_provider.dart';

/// Onboarding screen for new users to enter their platform handles.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _lcController = TextEditingController();
  final _cfController = TextEditingController();
  final _ccController = TextEditingController();
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _lcController.dispose();
    _cfController.dispose();
    _ccController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'SYSTEM.INIT',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'CONFIGURE\nIDENTITY',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Link your competitive programming profiles to track contests, ratings, and performance across platforms.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              // Handle inputs
              _HandleInput(
                label: 'LEETCODE',
                shortCode: 'LC',
                controller: _lcController,
                accentColor: AppColors.leetcodeAccent,
                hint: 'Enter LeetCode username',
                step: 0,
                currentStep: _currentStep,
                onFocus: () => setState(() => _currentStep = 0),
              ),
              const SizedBox(height: 16),
              _HandleInput(
                label: 'CODEFORCES',
                shortCode: 'CF',
                controller: _cfController,
                accentColor: AppColors.codeforcesAccent,
                hint: 'Enter Codeforces handle',
                step: 1,
                currentStep: _currentStep,
                onFocus: () => setState(() => _currentStep = 1),
              ),
              const SizedBox(height: 16),
              _HandleInput(
                label: 'CODECHEF',
                shortCode: 'CC',
                controller: _ccController,
                accentColor: AppColors.codechefAccent,
                hint: 'Enter CodeChef username',
                step: 2,
                currentStep: _currentStep,
                onFocus: () => setState(() => _currentStep = 2),
              ),

              const SizedBox(height: 24),

              // Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.outline,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can leave fields empty and configure them later in Profile settings.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          'INITIALIZE SYSTEM',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);

    final handles = <String, String>{};
    if (_lcController.text.trim().isNotEmpty) {
      handles['leetcode'] = _lcController.text.trim();
    }
    if (_cfController.text.trim().isNotEmpty) {
      handles['codeforces'] = _cfController.text.trim();
    }
    if (_ccController.text.trim().isNotEmpty) {
      handles['codechef'] = _ccController.text.trim();
    }

    // Capture provider references BEFORE async gap
    final settingsProvider = context.read<SettingsProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final contestProvider = context.read<ContestProvider>();
    final navigator = Navigator.of(context);

    await settingsProvider.saveHandles(handles);

    // Set handles (sync, no notifyListeners during build)
    profileProvider.setHandles(handles);

    // Navigate immediately, then load data in background
    navigator.pushReplacementNamed('/home');

    // Fire data fetches after navigation is complete
    Future.microtask(() {
      profileProvider.fetchAllProfiles();
      contestProvider.fetchContests();
    });
  }
}

class _HandleInput extends StatelessWidget {
  final String label;
  final String shortCode;
  final TextEditingController controller;
  final Color accentColor;
  final String hint;
  final int step;
  final int currentStep;
  final VoidCallback onFocus;

  const _HandleInput({
    required this.label,
    required this.shortCode,
    required this.controller,
    required this.accentColor,
    required this.hint,
    required this.step,
    required this.currentStep,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = step == currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  _getLogoPath(shortCode),
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (focused) {
              if (focused) onFocus();
            },
            child: TextField(
              controller: controller,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: accentColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLogoPath(String code) {
    switch (code) {
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
