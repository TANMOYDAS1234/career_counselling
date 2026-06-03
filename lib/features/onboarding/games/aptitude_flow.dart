import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_button.dart';
import 'aptitude_games.dart';
import 'black_box.dart';
import 'constraint_grid.dart';
import 'games_models.dart';
import 'sliding_tile.dart';

/// Drives the full Phase-6 game sequence: 4 adaptive aptitude games
/// (4 timed rounds each, weighted 0–8 score) → 3 persistence puzzles.
/// Calls [onComplete] with the aggregated [GameOutcome] when finished.
class AptitudeFlow extends StatefulWidget {
  const AptitudeFlow({super.key, required this.onComplete});

  final void Function(GameOutcome) onComplete;

  @override
  State<AptitudeFlow> createState() => _AptitudeFlowState();
}

enum _Step {
  intro,
  game,
  gameFeedback,
  tile,
  tileFeedback,
  grid,
  blackBox,
  finalFeedback,
}

class _AptitudeFlowState extends State<AptitudeFlow> {
  final _outcome = GameOutcome();

  _Step _step = _Step.intro;
  int _currentGame = 1; // 1..4
  int _round = 0; // 0..3
  int _difficulty = 2; // 1..3, tracked for adaptivity (matches web)
  final List<({bool correct, int time})> _answers = [];
  int _roundStart = 0;
  String _gameFeedback = '';

  int get _now => DateTime.now().millisecondsSinceEpoch;

  void _startGames() {
    setState(() {
      _step = _Step.game;
      _currentGame = 1;
      _round = 0;
      _difficulty = 2;
      _answers.clear();
      _roundStart = _now;
    });
  }

  void _onAnswer(bool isCorrect) {
    final time = _now - _roundStart;
    _answers.add((correct: isCorrect, time: time));
    final fast = time < 5000;
    if (isCorrect && fast && _difficulty < 3) {
      _difficulty++;
    } else if (!isCorrect && _difficulty > 1) {
      _difficulty--;
    }

    if (_round >= 3) {
      _gameFeedback = _buildGameFeedback(_answers);
      _storeScore(_weightedScore(_answers));
      setState(() => _step = _Step.gameFeedback);
    } else {
      setState(() {
        _round++;
        _roundStart = _now;
      });
    }
  }

  int _weightedScore(List<({bool correct, int time})> answers) {
    const fastThreshold = 5000;
    return answers.fold(0, (sum, a) {
      if (!a.correct) return sum;
      return sum + (a.time < fastThreshold ? 2 : 1);
    });
  }

  void _storeScore(int score) {
    switch (_currentGame) {
      case 1:
        _outcome.numberSenseScore = score;
      case 2:
        _outcome.wordSenseScore = score;
      case 3:
        _outcome.shapeSenseScore = score;
      case 4:
        _outcome.logicSenseScore = score;
    }
  }

  String _buildGameFeedback(List<({bool correct, int time})> answers) {
    const fastThreshold = 5000;
    final weighted = _weightedScore(answers);
    final correctCount = answers.where((a) => a.correct).length;
    final allCorrect = correctCount == 4;
    final avgTime = answers.fold(0, (s, a) => s + a.time) / answers.length;
    final fast = avgTime < fastThreshold;
    const labels = ['', 'quantitative reasoning', 'verbal reasoning', 'spatial reasoning', 'abstract reasoning'];
    final label = labels[_currentGame];

    if (weighted >= 7) {
      return 'Exceptional $label — you were both fast and accurate. This is natural fluency, not just learned skill. Careers that demand quick $label under pressure would suit you well.';
    } else if (weighted >= 5) {
      if (allCorrect && !fast) {
        return 'Strong $label — you got everything right but took your time. Accuracy is there; fluency is still building. You’d do well in roles where precision matters more than speed.';
      }
      return 'Good $label — solid accuracy with decent pace. You can handle careers that rely on this skill, though high-pressure, fast-turnaround roles may need more practice.';
    } else if (weighted >= 3) {
      if (correctCount >= 3 && !fast) {
        return 'Moderate $label — you’re accurate but slow. That tells us this doesn’t come naturally yet — you’re working it out rather than seeing it instantly. Careers requiring this skill are still possible with deliberate practice.';
      }
      return 'Developing $label — some correct answers but inconsistent. This isn’t a natural strength right now. We’ll weight your other aptitude scores more heavily in recommendations.';
    } else {
      final cap = '${label[0].toUpperCase()}${label.substring(1)}';
      return '$cap isn’t your natural strength — that’s honest data. Many successful careers don’t depend on this skill. Your other scores will carry more weight in your recommendations.';
    }
  }

  void _afterGameFeedback() {
    if (_currentGame < 4) {
      setState(() {
        _currentGame++;
        _round = 0;
        _difficulty = 2;
        _answers.clear();
        _roundStart = _now;
        _step = _Step.game;
      });
    } else {
      setState(() => _step = _Step.tile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: switch (_step) {
        _Step.intro => _Intro(onStart: _startGames),
        _Step.game => AptitudeGameView(
            key: ValueKey('g$_currentGame-$_round'),
            gameType: _currentGame,
            round: _round,
            onAnswer: _onAnswer,
          ),
        _Step.gameFeedback => _Feedback(
            title: gameNames[_currentGame],
            message: _gameFeedback,
            onContinue: _afterGameFeedback,
          ),
        _Step.tile => SlidingTile(
            onComplete: (r) {
              _outcome.persistence = r;
              setState(() => _step = _Step.tileFeedback);
            },
            onSkip: () => setState(() => _step = _Step.grid),
          ),
        _Step.tileFeedback => _PersistenceFeedback(
            result: _outcome.persistence!,
            onContinue: () => setState(() => _step = _Step.grid),
          ),
        _Step.grid => ConstraintGrid(
            onComplete: (r) {
              _outcome.constraintGrid = r;
              setState(() => _step = _Step.blackBox);
            },
            onSkip: () => setState(() => _step = _Step.blackBox),
          ),
        _Step.blackBox => BlackBox(
            onComplete: (r) {
              _outcome.blackBox = r;
              setState(() => _step = _Step.finalFeedback);
            },
            onSkip: () => widget.onComplete(_outcome),
          ),
        _Step.finalFeedback => _Feedback(
            title: 'All done!',
            message:
                'Great work — you finished every game. Your aptitude scores and problem-solving style are now part of your profile and will shape your recommendations.',
            buttonLabel: 'See my recommendations',
            onContinue: () => widget.onComplete(_outcome),
          ),
      },
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppGradientsTeal.teal,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.sports_esports_rounded, color: AppColors.white, size: 32),
        ),
        const SizedBox(height: AppSpacing.s3),
        Text('A few quick brain games',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.s2),
        const Text(
          'Four short rounds (number, word, shape, and logic sense) plus a couple of puzzles. They measure how you think — not what you’ve memorised. There are no wrong choices that count against you.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.neutral600, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.s3),
        GradientButton(label: 'Start the games', trailingIcon: Icons.arrow_forward_rounded, onPressed: onStart),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.title,
    required this.message,
    required this.onContinue,
    this.buttonLabel = 'Continue',
  });
  final String title;
  final String message;
  final VoidCallback onContinue;
  final String buttonLabel;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s2),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.primary100),
          ),
          child: Text(message, style: const TextStyle(fontSize: 14, color: AppColors.neutral800, height: 1.5)),
        ),
        const SizedBox(height: AppSpacing.s3),
        GradientButton(label: buttonLabel, trailingIcon: Icons.arrow_forward_rounded, onPressed: onContinue),
      ],
    );
  }
}

class _PersistenceFeedback extends StatelessWidget {
  const _PersistenceFeedback({required this.result, required this.onContinue});
  final PersistenceResult result;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('How you handled the puzzle',
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.s2),
        _row('Effort', result.effortRating),
        const SizedBox(height: AppSpacing.s1),
        _row('Approach', result.approachStyle),
        const SizedBox(height: AppSpacing.s3),
        GradientButton(
            label: 'Continue',
            gradient: AppGradientsTeal.teal,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: onContinue),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: AppColors.accent50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.accent200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.neutral800)),
        ],
      ),
    );
  }
}
