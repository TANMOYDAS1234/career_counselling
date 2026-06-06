import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
            TranslatedText("Here's what we noticed",
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
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
                  : _FeedbackPoints(message: state.feedbackMessage ?? ''),
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

/// Renders the AI feedback as up to 4 short bullet points (handles both
/// bullet-form and paragraph-form responses), in a friendly display font.
class _FeedbackPoints extends StatelessWidget {
  const _FeedbackPoints({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final points = _toPoints(message);
    if (points.isEmpty) {
      return TranslatedText(message,
          style: GoogleFonts.outfit(fontSize: 15.5, height: 1.5, color: AppColors.neutral700));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in points)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary600),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TranslatedText(p,
                      style: GoogleFonts.outfit(fontSize: 15.5, height: 1.4, color: AppColors.neutral800)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Splits feedback into 3–4 short points (newline/bullet first, else sentences).
  static List<String> _toPoints(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const [];
    var parts = text
        .split(RegExp(r'[\n•]'))
        .map((p) => p.replaceFirst(RegExp(r'^[\s\-*•.]+'), '').trim())
        .where((p) => p.length > 2)
        .toList();
    if (parts.length < 2) {
      parts = text
          .split(RegExp(r'(?<=[.!?])\s+'))
          .map((p) => p.trim())
          .where((p) => p.length > 2)
          .toList();
    }
    return parts.take(4).toList();
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
