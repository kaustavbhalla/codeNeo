import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Nothing OS-style toggle switch.
/// Monochrome, pill-shaped, mechanical feel.
class NothingToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const NothingToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 52,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height),
          color: value
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: height - 6,
            height: height - 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? AppColors.onPrimary
                  : AppColors.outline,
            ),
          ),
        ),
      ),
    );
  }
}
