import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/core_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/edubot_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/top_career.dart';
import 'recommendations_controller.dart';

const _rankEmoji = ['🎯', '💼', '🚀'];
const _rankColor = [AppColors.primary100, AppColors.secondary100, AppColors.emerald100];

class RecommendationsPage extends ConsumerWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careersAsync = ref.watch(recommendationsControllerProvider);

    return Scaffold(
      appBar: const EduBotAppBar(),
      body: AppBackground(
        child: careersAsync.when(
          loading: () => const _LoadingState(),
          error: (e, _) => _ErrorState(message: '$e'),
          data: (careers) => _Content(careers: careers),
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.careers});
  final List<TopCareer> careers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageH),
      children: [
        const SizedBox(height: AppSpacing.s1),
        const Center(child: GradientPill(text: 'Your Top Career Matches')),
        const SizedBox(height: AppSpacing.s2),
        Text('Your Top 3 Career\nRecommendations',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: AppSpacing.s1),
        const Text('Based on your profile, interests, and assessment results',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral600)),
        const SizedBox(height: AppSpacing.s4),
        if (careers.isEmpty)
          const _EmptyState()
        else
          for (var i = 0; i < careers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              child: _CareerCard(career: careers[i], index: i),
            ),
        const SizedBox(height: AppSpacing.s2),
        _RetakeCard(),
        const SizedBox(height: AppSpacing.s4),
      ],
    );
  }
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({required this.career, required this.index});
  final TopCareer career;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _rankColor[index % _rankColor.length],
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(_rankEmoji[index % _rankEmoji.length], style: const TextStyle(fontSize: 26)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${career.matchScore}%',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary600)),
                  const Text('Match', style: TextStyle(fontSize: 11, color: AppColors.neutral500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(career.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19)),
          const SizedBox(height: 8),
          Text(career.description,
              style: const TextStyle(color: AppColors.neutral600, height: 1.5, fontSize: 14)),
          const SizedBox(height: AppSpacing.s3),
          GradientButton(
            label: 'Know More',
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () => context.push('${Routes.payment}?job=$index'),
          ),
        ],
      ),
    );
  }
}

class _RetakeCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Column(
        children: [
          Text('Not satisfied with results?',
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          const Text('Retake the assessment with updated information to get better recommendations',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.s2),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(localStorageProvider).clearAssessmentCache();
              if (context.mounted) context.go(Routes.onboarding);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retake Assessment'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary600),
          SizedBox(height: AppSpacing.s2),
          Text('Fetching your career matches...',
              style: TextStyle(color: AppColors.primary600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutral400),
          const SizedBox(height: AppSpacing.s1),
          const Text('No recommendations yet. Complete the assessment to see your matches.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.s2),
          GradientButton(label: 'Take Assessment', onPressed: () => context.go(Routes.onboarding)),
        ],
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.destructive),
            const SizedBox(height: AppSpacing.s1),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.s2),
            GradientButton(
              label: 'Try Again',
              expand: false,
              onPressed: () => ref.invalidate(recommendationsControllerProvider),
            ),
          ],
        ),
      ),
    );
  }
}
