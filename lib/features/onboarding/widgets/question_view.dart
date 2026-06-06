import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/translated_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/onboarding_questions.dart';
import '../models/question.dart';
import '../onboarding_controller.dart';
import 'option_card.dart';

/// Renders the current assessment question and its Next/Skip controls.
class QuestionView extends ConsumerWidget {
  const QuestionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = ref.watch(onboardingControllerProvider.select((s) => s.question));
    final canProceed = ref.watch(onboardingControllerProvider.notifier).canProceed;
    // Re-read on any answer change so canProceed stays fresh.
    ref.watch(onboardingControllerProvider.select((s) => s.answers));
    final module = moduleForQuestion(q.number);
    final isModuleEnd = q.number == module.lastQuestion;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageH),
      child: AppCard(
        // Key by question number so per-question stateful children reset.
        key: ValueKey('q${q.number}'),
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuestionHeader(question: q),
            const SizedBox(height: AppSpacing.s3),
            _QuestionBody(question: q),
            const SizedBox(height: AppSpacing.s3),
            _Controls(question: q, isModuleEnd: isModuleEnd, canProceed: canProceed),
          ],
        ),
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: question.headerColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(question.headerIcon, color: AppColors.primary700),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(question.prompt,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text(_subtitle(question), style: const TextStyle(fontSize: 13, color: AppColors.neutral500)),
            ],
          ),
        ),
      ],
    );
  }

  String _subtitle(Question q) {
    final base = 'Question ${q.number} of 20';
    if (q.optional) return '$base • Optional';
    if (q.kind == QuestionKind.subjectMulti) return '$base • Select up to ${q.maxSelect}';
    if (q.kind == QuestionKind.multi) {
      if (q.minSelect == q.maxSelect) return '$base • Select your top ${q.maxSelect}';
      return '$base • Select up to ${q.maxSelect}';
    }
    return base;
  }
}

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody({required this.question});
  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (question.kind) {
      case QuestionKind.single:
        return _SingleChoice(question: question);
      case QuestionKind.singleAsList:
        return _SingleChoice(question: question, asList: true);
      case QuestionKind.multi:
        return _MultiChoice(question: question);
      case QuestionKind.text:
        return _TextAnswer(question: question);
      case QuestionKind.subjectMulti:
        return _SubjectGrid(question: question, multi: true);
      case QuestionKind.subjectSingle:
        return _SubjectGrid(question: question, multi: false);
      case QuestionKind.marks:
        return const _MarksGrid();
    }
  }
}

class _SingleChoice extends ConsumerWidget {
  const _SingleChoice({required this.question, this.asList = false});
  final Question question;
  final bool asList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);
    final selected = asList
        ? (ref.watch(onboardingControllerProvider.select(
            (s) => (s.answers[question.fieldKey] as List?)?.cast<String>() ?? const [])))
        : null;
    final selectedSingle = asList
        ? null
        : ref.watch(onboardingControllerProvider.select((s) => s.answers[question.fieldKey] as String?));

    return Column(
      children: [
        for (final opt in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s1),
            child: OptionCard(
              icon: opt.icon,
              label: opt.label,
              selected: asList ? selected!.contains(opt.value) : selectedSingle == opt.value,
              onTap: () => asList
                  ? c.selectSingleAsList(question.fieldKey, opt.value)
                  : c.selectSingle(question.fieldKey, opt.value),
            ),
          ),
      ],
    );
  }
}

class _MultiChoice extends ConsumerWidget {
  const _MultiChoice({required this.question});
  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);
    final selected = ref.watch(onboardingControllerProvider
        .select((s) => (s.answers[question.fieldKey] as List?)?.cast<String>() ?? const <String>[]));
    final maxSelect = question.maxSelect ?? question.options.length;
    final ranked = question.minSelect == question.maxSelect; // show rank numbers

    return Column(
      children: [
        for (final opt in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s1),
            child: OptionCard(
              icon: opt.icon,
              label: opt.label,
              selected: selected.contains(opt.value),
              enabled: selected.contains(opt.value) || selected.length < maxSelect,
              rank: ranked && selected.contains(opt.value) ? selected.indexOf(opt.value) + 1 : null,
              onTap: () => c.toggleMulti(question.fieldKey, opt.value, maxSelect),
            ),
          ),
        const SizedBox(height: 4),
        Text('${selected.length}/$maxSelect selected',
            style: const TextStyle(fontSize: 13, color: AppColors.neutral500)),
      ],
    );
  }
}

class _TextAnswer extends ConsumerStatefulWidget {
  const _TextAnswer({required this.question});
  final Question question;

  @override
  ConsumerState<_TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends ConsumerState<_TextAnswer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingControllerProvider.notifier).stringAnswer(widget.question.fieldKey);
    _controller = TextEditingController(text: existing ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.read(onboardingControllerProvider.notifier);
    return TextField(
      controller: _controller,
      maxLength: widget.question.maxLength,
      maxLines: 4,
      onChanged: (v) => c.setText(widget.question.fieldKey, v),
      decoration: InputDecoration(hintText: widget.question.placeholder),
    );
  }
}

class _SubjectGrid extends ConsumerWidget {
  const _SubjectGrid({required this.question, required this.multi});
  final Question question;
  final bool multi;

  Future<void> _addOther(BuildContext context, WidgetRef ref) async {
    final c = ref.read(onboardingControllerProvider.notifier);
    final tc = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TranslatedText('Add your subject'),
        content: TextField(
          controller: tc,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g., Urdu, Robotics, Statistics'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const TranslatedText('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, tc.text), child: const TranslatedText('Add')),
        ],
      ),
    );
    tc.dispose();
    final clean = name?.trim() ?? '';
    if (clean.isEmpty) return;
    c.addCustomSubject(clean);
    if (multi) {
      c.toggleSubject(clean, question.maxSelect ?? 3);
    } else {
      c.selectSingle('difficultSubject', clean);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);
    final favs = ref.watch(onboardingControllerProvider
        .select((s) => (s.answers['favoriteSubjects'] as List?)?.cast<String>() ?? const <String>[]));
    final difficult = ref.watch(onboardingControllerProvider.select((s) => s.answers['difficultSubject'] as String?));
    final basic = ref.watch(onboardingControllerProvider.select((s) => s.basic));
    final custom = ref.watch(onboardingControllerProvider
        .select((s) => (s.answers['customSubjects'] as List?)?.cast<String>() ?? const <String>[]));
    final maxSelect = question.maxSelect ?? 3;

    // Subjects relevant to this student's class/board, plus anything they typed.
    final base = subjectsFor(basic.classLevel, basic.board);
    final subjects = [...base, ...custom.where((s) => !base.contains(s))];

    return Column(
      children: [
        Wrap(
          spacing: AppSpacing.s1,
          runSpacing: AppSpacing.s1,
          children: [
            for (final subject in subjects)
              ChoiceChipCard(
                label: subject,
                color: multi ? AppColors.primary600 : AppColors.amber600,
                selected: multi ? favs.contains(subject) : difficult == subject,
                enabled: multi ? (favs.contains(subject) || favs.length < maxSelect) : true,
                onTap: () => multi
                    ? c.toggleSubject(subject, maxSelect)
                    : c.selectSingle('difficultSubject', subject),
              ),
            ChoiceChipCard(
              label: '+ Other',
              color: AppColors.neutral600,
              selected: false,
              onTap: () => _addOther(context, ref),
            ),
          ],
        ),
        if (multi) ...[
          const SizedBox(height: AppSpacing.s1),
          Text('${favs.length}/$maxSelect selected',
              style: const TextStyle(fontSize: 13, color: AppColors.neutral500)),
        ],
      ],
    );
  }
}

class _MarksGrid extends ConsumerWidget {
  const _MarksGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);
    final favs = ref.watch(onboardingControllerProvider
        .select((s) => (s.answers['favoriteSubjects'] as List?)?.cast<String>() ?? const <String>[]));
    final marks = ref.watch(onboardingControllerProvider
        .select((s) => (s.answers['subjectMarks'] as Map?)?.cast<String, String>() ?? const <String, String>{}));

    if (favs.isEmpty) {
      return const Text('Go back and pick your favourite subjects first.',
          style: TextStyle(color: AppColors.neutral500));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final subject in favs) ...[
          Text(subject,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.s1),
          Wrap(
            spacing: AppSpacing.s1,
            runSpacing: AppSpacing.s1,
            children: [
              for (final (value, label) in kMarkBands)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 92),
                  child: ChoiceChipCard(
                    label: label,
                    color: AppColors.emerald600,
                    selected: marks[subject] == value,
                    onTap: () => c.setMark(subject, value),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
        ],
      ],
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.question, required this.isModuleEnd, required this.canProceed});
  final Question question;
  final bool isModuleEnd;
  final bool canProceed;

  Future<void> _confirmSkip(BuildContext context, OnboardingController c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.amber600, size: 32),
        title: const TranslatedText('Skip this question?'),
        content: const TranslatedText(
          'Every answer shapes your career matches and report. Skipping this question makes your results less accurate and personalized. Skip anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const TranslatedText('Go back'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const TranslatedText('Skip anyway'),
          ),
        ],
      ),
    );
    if (ok == true) c.skip();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(onboardingControllerProvider.notifier);
    final label = isModuleEnd
        ? (question.number == 20 ? 'Complete Assessment' : 'Complete Module')
        : 'Next Question';

    final nextButton = GradientButton(
      label: label,
      trailingIcon: isModuleEnd ? Icons.check_rounded : Icons.arrow_forward_rounded,
      // Optional (text) questions can advance without input; others need an answer.
      onPressed: (question.optional || canProceed) ? () => c.next() : null,
    );

    // Back to the previous question (or basic info from Q1) — lets students fix answers.
    final backButton = SizedBox(
      height: 52,
      width: 52,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          c.previous();
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.neutral600,
          side: const BorderSide(color: AppColors.neutral300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
    );

    // Important questions are required to generate a result — no skip allowed.
    if (question.important) {
      return Row(
        children: [
          backButton,
          const SizedBox(width: AppSpacing.s2),
          Expanded(child: nextButton),
        ],
      );
    }

    return Row(
      children: [
        backButton,
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _confirmSkip(context, c),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const TranslatedText('Skip'),
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(child: nextButton),
      ],
    );
  }
}
