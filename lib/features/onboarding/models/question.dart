import 'package:flutter/material.dart';

/// How a question is rendered and how its answer is stored.
enum QuestionKind {
  /// Single choice; stores the option value as a String.
  single,

  /// Single choice but stored as a 1-element List (e.g. studyLocation).
  singleAsList,

  /// Multiple choice; stores a `List<String>` (bounded by [maxSelect]).
  multi,

  /// Free text; stores a String. Usually [optional].
  text,

  /// Pick favourite subjects from the subject grid (multi, max 3).
  subjectMulti,

  /// Pick one subject from the subject grid.
  subjectSingle,

  /// Per favourite subject, choose a marks band; stores `Map<String,String>`.
  marks,
}

class QuestionOption {
  const QuestionOption(this.value, this.icon, this.label);
  final String value;
  final IconData icon;
  final String label;
}

/// One assessment question. The catalog of all 20 lives in
/// `data/onboarding_questions.dart`.
class Question {
  const Question({
    required this.number,
    required this.module,
    required this.fieldKey,
    required this.kind,
    required this.prompt,
    required this.headerIcon,
    required this.headerColor,
    this.options = const [],
    this.optional = false,
    this.maxSelect,
    this.minSelect = 1,
    this.maxLength,
    this.placeholder,
  });

  final int number; // 1..20
  final int module; // 1..6
  final String fieldKey; // matches backend questionnaireData key
  final QuestionKind kind;
  final String prompt;
  final IconData headerIcon;
  final Color headerColor;
  final List<QuestionOption> options;
  final bool optional;
  final int? maxSelect;
  final int minSelect;
  final int? maxLength;
  final String? placeholder;
}

/// Metadata for one of the six assessment modules.
class ModuleInfo {
  const ModuleInfo(this.number, this.title, this.firstQuestion, this.lastQuestion);
  final int number;
  final String title;
  final int firstQuestion;
  final int lastQuestion;
}
