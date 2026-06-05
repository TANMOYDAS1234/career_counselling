import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/translated_text.dart';
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
            TranslatedText("Here's what we noticed", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: state.feedbackLoading
                  ? const _LoadingProgress()
                  : TranslatedText(
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

/// Animated progress bar + percentage shown while module feedback loads.
class _LoadingProgress extends StatelessWidget {
  const _LoadingProgress();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.05, end: 0.92),
      duration: const Duration(seconds: 6),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final pct = (value * 100).round();
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.neutral100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary600),
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$pct%  ',
                    style: const TextStyle(
                        color: AppColors.primary600, fontWeight: FontWeight.w700, fontSize: 13)),
                const Flexible(
                  child: TranslatedText('Analysing your answers...',
                      style: TextStyle(
                          color: AppColors.primary600, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
