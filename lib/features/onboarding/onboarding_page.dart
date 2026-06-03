import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/brand.dart';
import 'data/onboarding_questions.dart';
import 'games/aptitude_flow.dart';
import 'games/games_models.dart';
import 'onboarding_controller.dart';
import 'widgets/basic_info_step.dart';
import 'widgets/feedback_view.dart';
import 'widgets/question_view.dart';
import 'widgets/wizard_header.dart';

/// The assessment wizard: basic info → 20 questions across 6 modules, with
/// AI feedback between modules. On completion, saves and routes to results.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    Future<void> handleContinue() async {
      final done = controller.continueAfterFeedback();
      if (!done) return;
      final ok = await controller.submit();
      if (ok && context.mounted) context.go(Routes.recommendations);
    }

    Future<void> handleGamesComplete(GameOutcome outcome) async {
      controller.applyGameOutcome(outcome);
      final ok = await controller.submit();
      if (ok && context.mounted) context.go(Routes.recommendations);
    }

    final (title, subtitle) = _headerLabels(state);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [const BrandLogo(), const Spacer()]),
              ),
              if (state.stage != OnboardingStage.basicInfo)
                WizardHeader(progress: state.progress, title: title, subtitle: subtitle),
              Expanded(
                child: _Body(
                  stage: state.stage,
                  onContinue: handleContinue,
                  onGamesComplete: handleGamesComplete,
                ),
              ),
              if (state.submitting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Saving your assessment...'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  (String, String?) _headerLabels(OnboardingState state) {
    if (state.stage == OnboardingStage.basicInfo) return ('Get started', null);
    final m = moduleForQuestion(state.currentQuestion);
    return ('Module ${m.number} · ${m.title}', 'Question ${state.currentQuestion} of 20');
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stage, required this.onContinue, required this.onGamesComplete});
  final OnboardingStage stage;
  final VoidCallback onContinue;
  final void Function(GameOutcome) onGamesComplete;

  @override
  Widget build(BuildContext context) {
    final child = switch (stage) {
      OnboardingStage.basicInfo => const BasicInfoStep(),
      OnboardingStage.question => const QuestionView(),
      OnboardingStage.feedback => FeedbackView(onContinue: onContinue),
      OnboardingStage.games => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: AptitudeFlow(onComplete: onGamesComplete),
        ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(stage), child: child),
    );
  }
}
