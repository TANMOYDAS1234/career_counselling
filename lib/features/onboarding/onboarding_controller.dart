import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../models/onboarding_data.dart';
import '../auth/auth_controller.dart';
import 'data/onboarding_questions.dart';
import 'games/games_models.dart';
import 'models/question.dart';

enum OnboardingStage { basicInfo, question, feedback, games }

class OnboardingState {
  const OnboardingState({
    this.stage = OnboardingStage.basicInfo,
    this.basic = const OnboardingData(),
    this.currentQuestion = 1,
    this.answers = const {},
    this.basicLoading = false,
    this.feedbackLoading = false,
    this.feedbackMessage,
    this.submitting = false,
    this.error,
  });

  final OnboardingStage stage;
  final OnboardingData basic;
  final int currentQuestion;
  final Map<String, dynamic> answers;
  final bool basicLoading;
  final bool feedbackLoading;
  final String? feedbackMessage;
  final bool submitting;
  final String? error;

  Question get question => questionByNumber(currentQuestion);

  /// 0..1 progress across basic info (counts as step 0) + 20 questions.
  double get progress {
    if (stage == OnboardingStage.basicInfo) return 0;
    return currentQuestion / 20.0;
  }

  OnboardingState copyWith({
    OnboardingStage? stage,
    OnboardingData? basic,
    int? currentQuestion,
    Map<String, dynamic>? answers,
    bool? basicLoading,
    bool? feedbackLoading,
    String? feedbackMessage,
    bool clearFeedback = false,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      stage: stage ?? this.stage,
      basic: basic ?? this.basic,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      answers: answers ?? this.answers,
      basicLoading: basicLoading ?? this.basicLoading,
      feedbackLoading: feedbackLoading ?? this.feedbackLoading,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  late final ApiService _api = ref.read(apiServiceProvider);
  late final _storage = ref.read(localStorageProvider);

  String get _username =>
      ref.read(authControllerProvider).user?.email ??
      ref.read(localStorageProvider).username ??
      '';

  @override
  OnboardingState build() => const OnboardingState();

  // ── Answer accessors ───────────────────────────────────────────────────
  String? stringAnswer(String key) => state.answers[key] as String?;
  List<String> listAnswer(String key) =>
      (state.answers[key] as List?)?.cast<String>() ?? const [];
  Map<String, String> marksAnswer() =>
      (state.answers['subjectMarks'] as Map?)?.cast<String, String>() ?? const {};

  Map<String, dynamic> _put(String key, dynamic value) {
    final next = Map<String, dynamic>.from(state.answers);
    next[key] = value;
    return next;
  }

  // ── Mutations ─────────────────────────────────────────────────────────
  void updateBasic(OnboardingData data) => state = state.copyWith(basic: data);

  void selectSingle(String key, String value) =>
      state = state.copyWith(answers: _put(key, value));

  void selectSingleAsList(String key, String value) =>
      state = state.copyWith(answers: _put(key, [value]));

  void setText(String key, String value) =>
      state = state.copyWith(answers: _put(key, value));

  void toggleMulti(String key, String value, int maxSelect) {
    final current = List<String>.from(listAnswer(key));
    if (current.contains(value)) {
      current.remove(value);
    } else if (current.length < maxSelect) {
      current.add(value);
    }
    state = state.copyWith(answers: _put(key, current));
  }

  /// Q8 favourite subjects (drops associated marks if a subject is removed).
  void toggleSubject(String value, int maxSelect) {
    final current = List<String>.from(listAnswer('favoriteSubjects'));
    final marks = Map<String, String>.from(marksAnswer());
    if (current.contains(value)) {
      current.remove(value);
      marks.remove(value);
    } else if (current.length < maxSelect) {
      current.add(value);
    }
    final next = _put('favoriteSubjects', current);
    next['subjectMarks'] = marks;
    state = state.copyWith(answers: next);
  }

  void setMark(String subject, String band) {
    final marks = Map<String, String>.from(marksAnswer());
    marks[subject] = band;
    state = state.copyWith(answers: _put('subjectMarks', marks));
  }

  // ── Validation for the current question ────────────────────────────────
  bool get canProceed {
    final q = state.question;
    switch (q.kind) {
      case QuestionKind.single:
        return stringAnswer(q.fieldKey) != null;
      case QuestionKind.singleAsList:
        return listAnswer(q.fieldKey).isNotEmpty;
      case QuestionKind.multi:
        return listAnswer(q.fieldKey).length >= q.minSelect;
      case QuestionKind.subjectMulti:
        return listAnswer('favoriteSubjects').length >= q.minSelect;
      case QuestionKind.subjectSingle:
        return stringAnswer('difficultSubject') != null;
      case QuestionKind.marks:
        final favs = listAnswer('favoriteSubjects');
        final marks = marksAnswer();
        return favs.isNotEmpty && favs.every(marks.containsKey);
      case QuestionKind.text:
        return true; // optional
    }
  }

  // ── Flow ──────────────────────────────────────────────────────────────
  Future<void> submitBasicInfo() async {
    state = state.copyWith(basicLoading: true, clearError: true);
    try {
      // Best-effort persist; don't block the assessment if it fails.
      if (_username.isNotEmpty) await _api.saveOnboarding(_username, state.basic);
    } catch (_) {/* ignore */}
    state = state.copyWith(
      basicLoading: false,
      stage: OnboardingStage.question,
      currentQuestion: 1,
    );
  }

  /// Advance from the current question. If it's the last in its module,
  /// fetch AI module feedback; otherwise go to the next question.
  Future<void> next() async {
    final q = state.question;
    final module = moduleForQuestion(q.number);
    if (q.number == module.lastQuestion) {
      await _loadFeedback(module.number);
    } else {
      state = state.copyWith(currentQuestion: q.number + 1);
    }
  }

  /// Skip an optional text question (clears its value) then advance.
  Future<void> skip() async {
    final q = state.question;
    if (state.answers.containsKey(q.fieldKey)) {
      final cleared = Map<String, dynamic>.from(state.answers)..remove(q.fieldKey);
      state = state.copyWith(answers: cleared);
    }
    await next();
  }

  /// Step back: to the previous question, or to the basic-info screen from Q1.
  /// Answers already given are kept so the student can review/change them.
  void previous() {
    final q = state.currentQuestion;
    if (q <= 1) {
      state = state.copyWith(stage: OnboardingStage.basicInfo);
    } else {
      state = state.copyWith(stage: OnboardingStage.question, currentQuestion: q - 1);
    }
  }

  Future<void> _loadFeedback(int moduleNumber) async {
    state = state.copyWith(stage: OnboardingStage.feedback, feedbackLoading: true, clearFeedback: true);
    try {
      final fb = await _api.generateModuleFeedback(moduleNumber, jsonEncode(state.answers));
      state = state.copyWith(feedbackLoading: false, feedbackMessage: fb ?? _fallbackFeedback);
    } catch (_) {
      state = state.copyWith(feedbackLoading: false, feedbackMessage: _fallbackFeedback);
    }
  }

  static const _fallbackFeedback =
      "Great progress! Your answers are helping us understand how you think and what you value. Let's keep going.";

  /// Continue past a module-feedback screen.
  /// Returns true when the questionnaire is complete AND the games are done
  /// (caller should submit). After the last module, routes into the aptitude
  /// games stage instead of submitting immediately.
  bool continueAfterFeedback() {
    if (state.currentQuestion >= 20) {
      state = state.copyWith(stage: OnboardingStage.games, clearFeedback: true);
      return false;
    }
    state = state.copyWith(
      stage: OnboardingStage.question,
      currentQuestion: state.currentQuestion + 1,
      clearFeedback: true,
    );
    return false;
  }

  /// Merges aptitude-game scores + persistence telemetry into the answers,
  /// to be saved with the questionnaire on submit.
  void applyGameOutcome(GameOutcome outcome) {
    final next = Map<String, dynamic>.from(state.answers);
    outcome.toAnswers().forEach((k, v) {
      if (v != null) next[k] = v;
    });
    state = state.copyWith(answers: next);
  }

  /// Persist the full questionnaire. Returns true on success.
  Future<bool> submit() async {
    state = state.copyWith(submitting: true, clearError: true);
    // Persist a personalization profile for the job-detail AI prompts.
    try {
      await _storage.setUserProfileRaw(jsonEncode(_buildUserProfile()));
    } catch (_) {/* non-critical */}
    try {
      final ok = _username.isEmpty
          ? false
          : await _api.saveQuestionnaire(_username, state.answers);
      state = state.copyWith(submitting: false);
      if (!ok) state = state.copyWith(error: 'Could not save your assessment. Please try again.');
      return ok;
    } on ApiException catch (e) {
      state = state.copyWith(submitting: false, error: e.message);
      return false;
    }
  }

  /// Compact, AI-friendly profile derived from the basic info + answers. The
  /// backend (`generate_detailed_content`) reads `education`/`testimony` and
  /// also interpolates the whole map, so richer context = more personalized.
  Map<String, dynamic> _buildUserProfile() {
    final b = state.basic;
    final a = state.answers;
    const eduCode = {
      '9': 'class-9', '10': 'class-10', '11': 'class-11', '12': 'class-12',
      'graduation': 'graduation', 'graduated': 'graduated', 'postgrad': 'postgrad',
    };
    const eduLabel = {
      '9': 'Class 9', '10': 'Class 10', '11': 'Class 11', '12': 'Class 12',
      'graduation': 'Graduation (pursuing)', 'graduated': 'Graduated', 'postgrad': 'Postgraduate',
    };
    final testimony = ((a['careerThinking'] as String?)?.trim().isNotEmpty ?? false)
        ? a['careerThinking'] as String
        : ((a['selfInitiated'] as String?) ?? '');
    return {
      'name': b.name,
      'education': eduCode[b.classLevel] ?? b.classLevel,
      'education_label': eduLabel[b.classLevel] ?? b.classLevel,
      'board': b.board,
      'district': b.district,
      'favorite_subjects': a['favoriteSubjects'] ?? const [],
      'difficult_subject': a['difficultSubject'] ?? '',
      'subject_marks': a['subjectMarks'] ?? const {},
      'study_experience': a['studyExperience'] ?? '',
      'interests': a['outsideActivities'] ?? const [],
      'career_values': a['careerValues'] ?? const [],
      'five_year_vision': a['fiveYearVision'] ?? '',
      'aptitude': {
        'quantitative': a['numberSenseScore'],
        'verbal': a['wordSenseScore'],
        'spatial': a['shapeSenseScore'],
        'logical': a['logicSenseScore'],
      },
      'testimony': testimony,
    };
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
