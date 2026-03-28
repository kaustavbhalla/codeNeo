import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Dot-matrix progress indicator — 5 dots with sequential opacity animation.
class DotMatrixLoader extends StatefulWidget {
  final double dotSize;
  final double spacing;
  final Color color;

  const DotMatrixLoader({
    super.key,
    this.dotSize = 8,
    this.spacing = 6,
    this.color = AppColors.primary,
  });

  @override
  State<DotMatrixLoader> createState() => _DotMatrixLoaderState();
}

class _DotMatrixLoaderState extends State<DotMatrixLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final delay = index * 0.15;
            final opacity = _calculateOpacity(_controller.value, delay);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _calculateOpacity(double animValue, double delay) {
    double adjusted = (animValue - delay) % 1.0;
    if (adjusted < 0.3) {
      return 0.2 + (adjusted / 0.3) * 0.8;
    } else if (adjusted < 0.6) {
      return 1.0 - ((adjusted - 0.3) / 0.3) * 0.8;
    }
    return 0.2;
  }
}
