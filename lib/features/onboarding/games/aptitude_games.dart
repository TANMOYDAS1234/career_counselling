import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// One question in an aptitude game. [correct] is compared by value against the
/// chosen option (number, string, or "Option A".."Option D" for image rounds).
class GameQuestion {
  const GameQuestion({
    required this.type,
    required this.question,
    required this.correct,
    this.options = const [],
    this.words = const [],
    this.questionImage,
    this.optionImages = const [],
    this.difficulty = 'medium',
  });

  final String type;
  final String question;
  final Object correct;
  final List<Object> options;
  final List<String> words;
  final String? questionImage;
  final List<String> optionImages;
  final String difficulty;

  bool get isImage => questionImage != null && optionImages.isNotEmpty;
}

String _asset(String webPath) =>
    'assets/images/games/${webPath.split('/').last}';

// ── Game 1 — Number Sense ────────────────────────────────────────────────────
const _numberSense = <GameQuestion>[
  GameQuestion(type: 'sequence', question: '2, 4, 8, 16, ?', options: [24, 32, 20, 64], correct: 32, difficulty: 'easy'),
  GameQuestion(type: 'sequence', question: '3, 6, 11, 18, 27, ?', options: [35, 36, 38, 40], correct: 38, difficulty: 'medium'),
  GameQuestion(
      type: 'arithmetic',
      question: 'A shopkeeper buys for ₹80, sells for ₹100. What is the profit percentage?',
      options: ['15%', '20%', '25%', '80%'],
      correct: '25%',
      difficulty: 'medium'),
  GameQuestion(
      type: 'reasoning',
      question: '5 machines make 5 widgets in 5 minutes. How long for 100 machines to make 100 widgets?',
      options: ['1 min', '5 min', '20 min', '100 min'],
      correct: '5 min',
      difficulty: 'hard'),
];

// ── Game 2 — Word Sense ──────────────────────────────────────────────────────
const _wordSense = <GameQuestion>[
  GameQuestion(
      type: 'odd-one-out',
      question: 'Which word does not belong?',
      words: ['Rose', 'Lily', 'Oak', 'Jasmine'],
      correct: 'Oak',
      difficulty: 'easy'),
  GameQuestion(
      type: 'analogy',
      question: 'Doctor is to Hospital as Teacher is to ___',
      options: ['Student', 'School', 'Book', 'Lesson'],
      correct: 'School',
      difficulty: 'medium'),
  GameQuestion(
      type: 'meaning',
      question: "Which means the same as: 'She rarely misses a deadline'?",
      options: [
        'She often misses deadlines',
        'She almost always meets deadlines',
        'She has no deadlines',
        'She sometimes meets deadlines',
      ],
      correct: 'She almost always meets deadlines',
      difficulty: 'medium'),
  GameQuestion(
      type: 'vocabulary',
      question: "The plan was meticulous. 'Meticulous' most nearly means:",
      options: ['Careless', 'Very careful', 'Quick', 'Expensive'],
      correct: 'Very careful',
      difficulty: 'hard'),
];

// ── Game 3 — Shape Sense (spatial) ───────────────────────────────────────────
final _shapeSense = <GameQuestion>[
  GameQuestion(
      type: 'rotation',
      question: 'Which of these is the same L-shaped block simply rotated (not flipped)?',
      questionImage: _asset('/images/g3_q1_question.png'),
      optionImages: [
        _asset('/images/g3_q1_option_A.png'),
        _asset('/images/g3_q1_option_B.png'),
        _asset('/images/g3_q1_option_C.png'),
        _asset('/images/g3_q1_option_D.png'),
      ],
      correct: 'Option A',
      difficulty: 'easy'),
  const GameQuestion(
      type: 'cube-counting',
      question: 'A 3×3×3 stack with one column of 3 removed. How many small cubes are here?',
      options: [21, 23, 24, 27],
      correct: 24,
      difficulty: 'medium'),
  GameQuestion(
      type: 'net-folding',
      question: 'Which of these boxes can be folded from this net?',
      questionImage: _asset('/images/g3_q3_question.png'),
      optionImages: [
        _asset('/images/g3_q3_option_A.png'),
        _asset('/images/g3_q3_option_B.png'),
        _asset('/images/g3_q3_option_C.png'),
        _asset('/images/g3_q3_option_D.png'),
      ],
      correct: 'Option A',
      difficulty: 'medium'),
  GameQuestion(
      type: 'mental-assembly',
      question: 'Which single shape do these two pieces make if joined along the marked edge?',
      questionImage: _asset('/images/g3_q4_question.png'),
      optionImages: [
        _asset('/images/g3_q4_option_A.png'),
        _asset('/images/g3_q4_option_B.png'),
        _asset('/images/g3_q4_option_C.png'),
        _asset('/images/g3_q4_option_D.png'),
      ],
      correct: 'Option B',
      difficulty: 'hard'),
];

// ── Game 4 — Logic Sense (abstract) ──────────────────────────────────────────
final _logicSense = <GameQuestion>[
  const GameQuestion(
      type: 'matrix',
      question: 'Three rows of dots: row 1 has 1-2-3, row 2 has 2-3-4, row 3 has 3-4-?',
      options: [4, 5, 6, 7],
      correct: 5,
      difficulty: 'easy'),
  const GameQuestion(
      type: 'rule-finding',
      question: 'If ◆◆ = 4, ◆◆◆ = 9, ◆◆◆◆ = 16, then ◆◆◆◆◆ = ?',
      options: [18, 20, 25, 30],
      correct: 25,
      difficulty: 'medium'),
  GameQuestion(
      type: 'pattern-series',
      question: 'A figure rotates 90° clockwise and gains one dot at each step. What comes next?',
      questionImage: _asset('/images/g4_q3_question.png'),
      optionImages: [
        _asset('/images/g4_q3_option_A.png'),
        _asset('/images/g4_q3_option_B.png'),
        _asset('/images/g4_q3_option_C.png'),
        _asset('/images/g4_q3_option_D.png'),
      ],
      correct: 'Option C',
      difficulty: 'medium'),
  const GameQuestion(
      type: 'deduction',
      question: 'All bloops are razzies. All razzies are lazzies. Are all bloops definitely lazzies?',
      options: ['Yes', 'No', 'Cannot say'],
      correct: 'Yes',
      difficulty: 'hard'),
];

const gameNames = ['', 'Number Sense', 'Word Sense', 'Shape Sense', 'Logic Sense'];
const _gameColors = [AppColors.primary600, AppColors.primary600, AppColors.secondary600, AppColors.emerald600, AppColors.amber600];

List<GameQuestion> questionsForGame(int gameType) {
  switch (gameType) {
    case 1:
      return _numberSense;
    case 2:
      return _wordSense;
    case 3:
      return _shapeSense;
    case 4:
      return _logicSense;
    default:
      return const [];
  }
}

/// Renders the current question of [gameType] at [round] (0–3) and reports the
/// chosen answer's correctness via [onAnswer]. Ported from the web `AptitudeGames`.
class AptitudeGameView extends StatefulWidget {
  const AptitudeGameView({
    super.key,
    required this.gameType,
    required this.round,
    required this.onAnswer,
  });

  final int gameType;
  final int round;
  final void Function(bool isCorrect) onAnswer;

  @override
  State<AptitudeGameView> createState() => _AptitudeGameViewState();
}

class _AptitudeGameViewState extends State<AptitudeGameView> {
  Object? _selected;

  @override
  void didUpdateWidget(AptitudeGameView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.round != widget.round || oldWidget.gameType != widget.gameType) {
      _selected = null;
    }
  }

  void _answer(Object option) {
    if (_selected != null) return;
    setState(() => _selected = option);
    final q = questionsForGame(widget.gameType)[widget.round];
    final correct = option == q.correct;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) widget.onAnswer(correct);
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = questionsForGame(widget.gameType);
    if (widget.round >= questions.length) return const SizedBox.shrink();
    final q = questions[widget.round];
    final color = _gameColors[widget.gameType];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${gameNames[widget.gameType]} — Question ${widget.round + 1} of 4',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
            ),
            Row(
              children: List.generate(
                4,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: i <= widget.round ? color : AppColors.neutral300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        if (q.isImage) ...[
          _QuestionImage(path: q.questionImage!, tint: color),
          const SizedBox(height: AppSpacing.s2),
          Text(q.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.neutral800)),
          const SizedBox(height: AppSpacing.s2),
          _ImageOptionsGrid(q: q, selected: _selected, color: color, onTap: _answer),
        ] else if (q.words.isNotEmpty) ...[
          Text(q.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.neutral800)),
          const SizedBox(height: AppSpacing.s2),
          _WordsGrid(q: q, selected: _selected, color: color, onTap: _answer),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(q.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
          ),
          const SizedBox(height: AppSpacing.s3),
          _TextOptions(q: q, selected: _selected, color: color, onTap: _answer),
        ],
      ],
    );
  }
}

class _QuestionImage extends StatelessWidget {
  const _QuestionImage({required this.path, required this.tint});
  final String path;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(color: tint.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Image.asset(path, height: 150, fit: BoxFit.contain),
    );
  }
}

class _ImageOptionsGrid extends StatelessWidget {
  const _ImageOptionsGrid({required this.q, required this.selected, required this.color, required this.onTap});
  final GameQuestion q;
  final Object? selected;
  final Color color;
  final void Function(Object) onTap;
  @override
  Widget build(BuildContext context) {
    const labels = ['Option A', 'Option B', 'Option C', 'Option D'];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s2,
      crossAxisSpacing: AppSpacing.s2,
      childAspectRatio: 1.1,
      children: [
        for (var i = 0; i < q.optionImages.length; i++)
          _Tappable(
            selected: selected == labels[i],
            color: color,
            onTap: () => onTap(labels[i]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Image.asset(q.optionImages[i], fit: BoxFit.contain)),
                const SizedBox(height: 4),
                Text(labels[i],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.neutral800)),
              ],
            ),
          ),
      ],
    );
  }
}

class _WordsGrid extends StatelessWidget {
  const _WordsGrid({required this.q, required this.selected, required this.color, required this.onTap});
  final GameQuestion q;
  final Object? selected;
  final Color color;
  final void Function(Object) onTap;
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s2,
      crossAxisSpacing: AppSpacing.s2,
      childAspectRatio: 2.4,
      children: [
        for (final w in q.words)
          _Tappable(
            selected: selected == w,
            color: color,
            onTap: () => onTap(w),
            child: Center(
              child: Text(w,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.neutral900)),
            ),
          ),
      ],
    );
  }
}

class _TextOptions extends StatelessWidget {
  const _TextOptions({required this.q, required this.selected, required this.color, required this.onTap});
  final GameQuestion q;
  final Object? selected;
  final Color color;
  final void Function(Object) onTap;
  @override
  Widget build(BuildContext context) {
    // Short numeric/percentage options → 2-col grid; long text → single column.
    final allShort = q.options.every((o) => o.toString().length <= 8);
    if (allShort) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.s2,
        crossAxisSpacing: AppSpacing.s2,
        childAspectRatio: 2.4,
        children: [
          for (final o in q.options)
            _Tappable(
              selected: selected == o,
              color: color,
              onTap: () => onTap(o),
              child: Center(
                child: Text('$o',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
              ),
            ),
        ],
      );
    }
    return Column(
      children: [
        for (final o in q.options)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s1),
            child: _Tappable(
              selected: selected == o,
              color: color,
              onTap: () => onTap(o),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('$o',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.neutral900)),
              ),
            ),
          ),
      ],
    );
  }
}

class _Tappable extends StatelessWidget {
  const _Tappable({required this.child, required this.selected, required this.color, required this.onTap});
  final Widget child;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(AppSpacing.s2),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: selected ? color : AppColors.neutral200, width: selected ? 2 : 1),
        ),
        child: child,
      ),
    );
  }
}
