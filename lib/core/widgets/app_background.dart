import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Recreates the web `.abstract-bg`: neutral-50 base with three faint radial
/// tints (indigo, purple, teal). Wrap a page body in this.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.neutral50),
      child: Stack(
        children: [
          const Positioned.fill(child: _RadialTints()),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _RadialTints extends StatelessWidget {
  const _RadialTints();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _tint(const Alignment(-0.6, -0.4), AppColors.primary500.withValues(alpha: 0.05)),
        _tint(const Alignment(0.7, 0.5), AppColors.secondary500.withValues(alpha: 0.05)),
        _tint(const Alignment(0, 0), AppColors.accent500.withValues(alpha: 0.04)),
      ],
    );
  }

  Widget _tint(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
