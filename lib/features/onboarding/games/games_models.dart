// Result/telemetry types for the persistence puzzles, ported from the web
// `aptitude-games.tsx` (`TileTelemetry`, `PersistenceResult`,
// `ConstraintGridResult`, `BlackBoxResult`).

class TileTelemetry {
  TileTelemetry({
    required this.tier,
    required this.totalMoves,
    required this.optimalMoves,
    required this.ratio,
    required this.timeToFirstMove,
    required this.reversals,
    required this.hintsUsed,
    required this.solved,
    required this.quitTime,
    required this.manhattanLog,
    required this.configIndex,
  });

  final int tier;
  final int totalMoves;
  final int optimalMoves;
  final double ratio;
  final int timeToFirstMove; // ms
  final int reversals;
  final int hintsUsed;
  final bool solved;
  final int? quitTime; // ms since tier start; null if solved
  final List<int> manhattanLog;
  final int configIndex;
}

class PersistenceResult {
  PersistenceResult({
    required this.highestTier,
    required this.tierTelemetry,
    required this.effortRating,
    required this.approachStyle,
    required this.counselorFlags,
  });

  final int highestTier;
  final List<TileTelemetry> tierTelemetry;
  final String effortRating;
  final String approachStyle;
  final List<String> counselorFlags;
}

class ConstraintGridResult {
  ConstraintGridResult({
    required this.scanTimeMs,
    required this.foundEasyEntryFirst,
    required this.mistakesMade,
    required this.mistakesUndone,
    required this.hintUsed,
    required this.solved,
    required this.shutdownWithoutAttempt,
    required this.approachLabel,
    required this.counselorFlag,
  });

  final int scanTimeMs;
  final bool foundEasyEntryFirst;
  final int mistakesMade;
  final int mistakesUndone;
  final bool hintUsed;
  final bool solved;
  final bool shutdownWithoutAttempt;
  final String approachLabel;
  final String? counselorFlag;
}

class BlackBoxResult {
  BlackBoxResult({
    required this.inputsTested,
    required this.strategicInputs,
    required this.guessCount,
    required this.wrongGuesses,
    required this.guessesConvergingToAnswer,
    required this.solved,
    required this.abandonedLastGuess,
    required this.approachLabel,
    required this.counselorFlag,
  });

  final int inputsTested;
  final int strategicInputs;
  final int guessCount;
  final List<List<double>> wrongGuesses;
  final bool guessesConvergingToAnswer;
  final bool solved;
  final bool abandonedLastGuess;
  final String approachLabel;
  final String? counselorFlag;
}

/// Aggregated game payload merged into the questionnaire answers on submit.
/// Keys match the backend `save_questionnaire_data` expectations.
class GameOutcome {
  GameOutcome({
    this.numberSenseScore,
    this.wordSenseScore,
    this.shapeSenseScore,
    this.logicSenseScore,
    this.persistence,
    this.constraintGrid,
    this.blackBox,
  });

  int? numberSenseScore;
  int? wordSenseScore;
  int? shapeSenseScore;
  int? logicSenseScore;
  PersistenceResult? persistence;
  ConstraintGridResult? constraintGrid;
  BlackBoxResult? blackBox;

  /// Synthesizes a unified effort rating + approach style across all three
  /// persistence tasks (port of the web `synthesizeProfile`).
  ({String effortRating, String approachStyle}) _synthesize() {
    final t1Effort = persistence?.effortRating ?? '';
    final t3Abandoned = blackBox?.abandonedLastGuess ?? false;
    final t2Shutdown = constraintGrid?.shutdownWithoutAttempt ?? false;

    var effortRating = t1Effort.isNotEmpty
        ? t1Effort
        : 'You engage with familiar problems confidently but step back from unfamiliar ones.';

    if (effortRating.contains('move on quickly') && (blackBox?.strategicInputs ?? 0) >= 4) {
      effortRating =
          'You engage with familiar problems confidently but step back from unfamiliar ones.';
    }
    if (t2Shutdown && t3Abandoned) {
      effortRating =
          'You move on quickly when a problem feels unsolvable — which has both strengths and costs depending on the career.';
    }

    final signals = <String>[];
    if (persistence?.approachStyle != null) signals.add(persistence!.approachStyle);
    switch (constraintGrid?.approachLabel) {
      case 'systematic-analytical':
        signals.add('Systematic — you gather information before acting.');
      case 'cautious':
        signals.add('Cautious — you prefer to understand the full picture before committing to any move.');
      case 'intuitive-adaptive':
        signals.add('Intuitive — you act first and adjust from feedback.');
    }
    switch (blackBox?.approachLabel) {
      case 'scientific-reasoning':
      case 'observational-weak-synthesis':
        signals.add('Systematic — you gather information before acting.');
      case 'intuitive':
      case 'intuitive-lucky':
        signals.add('Intuitive — you act first and adjust from feedback.');
    }

    final systematic = signals.where((s) => s.startsWith('Systematic')).length;
    final intuitive = signals.where((s) => s.startsWith('Intuitive')).length;
    final cautious = signals.where((s) => s.startsWith('Cautious')).length;

    var approachStyle = persistence?.approachStyle ?? 'Intuitive — you act first and adjust from feedback.';
    if (systematic >= 2) {
      approachStyle = 'Systematic — you gather information before acting.';
    } else if (cautious >= 2) {
      approachStyle = 'Cautious — you prefer to understand the full picture before committing to any move.';
    } else if (intuitive >= 2) {
      approachStyle = 'Intuitive — you act first and adjust from feedback.';
    }

    return (effortRating: effortRating, approachStyle: approachStyle);
  }

  /// Map of game fields to merge into the questionnaire `answers`.
  Map<String, dynamic> toAnswers() {
    final synth = _synthesize();
    return {
      'numberSenseScore': numberSenseScore,
      'wordSenseScore': wordSenseScore,
      'shapeSenseScore': shapeSenseScore,
      'logicSenseScore': logicSenseScore,
      'persistenceEffortRating': synth.effortRating,
      'persistenceApproachStyle': synth.approachStyle,
      'persistenceCounselorFlags': [
        ...?persistence?.counselorFlags,
        if (constraintGrid?.counselorFlag != null) constraintGrid!.counselorFlag,
        if (blackBox?.counselorFlag != null) blackBox!.counselorFlag,
      ],
      'persistenceHighestTier': persistence?.highestTier,
      'constraintGridApproach': constraintGrid?.approachLabel,
      'constraintGridSolved': constraintGrid?.solved,
      'constraintGridCounselorFlag': constraintGrid?.counselorFlag,
      'blackBoxApproach': blackBox?.approachLabel,
      'blackBoxSolved': blackBox?.solved,
      'blackBoxAbandonedLastGuess': blackBox?.abandonedLastGuess,
      'blackBoxCounselorFlag': blackBox?.counselorFlag,
    };
  }
}
