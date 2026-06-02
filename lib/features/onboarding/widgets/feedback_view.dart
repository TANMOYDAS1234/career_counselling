import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../onboarding_controller.dart';

/// "Here's what we noticed" — AI module feedback between modules.
class FeedbackView extends ConsumerWidget {
  const FeedbackView({super.key, required this.onContinue});

  /// Called when the user taps continue; the orchestrator decides whether to
  /// advance to the next module or submit.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final isLast = state.currentQuestion >= 20;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageH),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary50, AppColors.secondary50]),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary200, width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(gradient: AppGradients.primaryButton, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 30),
            ),
            const SizedBox(height: AppSpacing.s2),
            Text("Here's what we noticed", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: state.feedbackLoading
                  ? Column(
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary600),
                        const SizedBox(height: AppSpacing.s2),
                        Text('Analysing your answers...',
                            style: TextStyle(color: AppColors.primary600, fontWeight: FontWeight.w600)),
                      ],
                    )
                  : Text(
                      state.feedbackMessage ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.55, color: AppColors.neutral700),
                    ),
            ),
            const SizedBox(height: AppSpacing.s3),
            GradientButton(
              label: isLast ? 'View Your Career Matches' : 'Continue to Next Module',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: state.feedbackLoading ? null : onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
