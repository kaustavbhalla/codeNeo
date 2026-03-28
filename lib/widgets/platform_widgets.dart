import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/platform_utils.dart';

/// Platform icon/badge widget — uses actual platform logos.
class PlatformBadge extends StatelessWidget {
  final Platform platform;
  final double size;
  final bool showLabel;

  const PlatformBadge({
    super.key,
    required this.platform,
    this.size = 32,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: Image.asset(
            _getLogoPath(),
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackBadge(),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            platform.displayName.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  String _getLogoPath() {
    switch (platform) {
      case Platform.leetcode:
        return 'assets/logos/leetcodelogo.png';
      case Platform.codeforces:
        return 'assets/logos/code-forces.png';
      case Platform.codechef:
        return 'assets/logos/codecheflogo.png';
    }
  }

  /// Fallback if the image file isn't found.
  Widget _fallbackBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          platform.shortName,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

/// Platform filter chips.
class PlatformFilterChips extends StatelessWidget {
  final Platform? selectedPlatform;
  final ValueChanged<Platform?> onSelected;

  const PlatformFilterChips({
    super.key,
    required this.selectedPlatform,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'ALL',
          isSelected: selectedPlatform == null,
          onTap: () => onSelected(null),
        ),
        const SizedBox(width: 8),
        ...Platform.values.map((p) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _FilterChip(
            label: p.shortName,
            isSelected: selectedPlatform == p,
            onTap: () => onSelected(p),
          ),
        )),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Surface card — tonal layering card without borders.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? AppColors.surfaceContainer,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}
