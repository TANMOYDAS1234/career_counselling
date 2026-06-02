import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/brand.dart';

/// Temporary themed screen for routes that will be implemented in a later phase.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, required this.phase});

  final String title;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(),
                  const SizedBox(height: AppSpacing.s5),
                  Icon(Icons.construction_rounded, size: 56, color: AppColors.primary400),
                  const SizedBox(height: AppSpacing.s2),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    'Coming in $phase',
                    style: const TextStyle(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  OutlinedButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
