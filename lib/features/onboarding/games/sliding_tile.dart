import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import 'games_models.dart';

// Fixed solvable configurations (port of TILE_CONFIGS).
class _TileConfig {
  const _TileConfig({required this.tier, required this.state, required this.optimal, required this.solution});
  final int tier;
  final List<int> state;
  final int optimal;
  final List<String> solution;
}

const _configs = <_TileConfig>[
  _TileConfig(tier: 1, state: [1, 3, 8, 4, 6, 2, 0, 7, 5], optimal: 12, solution: [
    'right', 'up', 'right', 'up', 'left', 'down', 'down', 'right', 'up', 'left', 'down', 'right'
  ]),
  _TileConfig(tier: 2, state: [5, 4, 1, 3, 0, 8, 7, 6, 2], optimal: 16, solution: [
    'right', 'down', 'left', 'up', 'left', 'up', 'right', 'right', 'down', 'left', 'left', 'up', 'right', 'right', 'down', 'down'
  ]),
  _TileConfig(tier: 3, state: [2, 3, 4, 8, 0, 5, 1, 6, 7], optimal: 22, solution: [
    'left', 'down', 'right', 'right', 'up', 'up', 'left', 'left', 'down', 'right', 'down', 'left', 'up', 'right', 'right', 'down', 'left', 'left', 'up', 'right', 'right', 'down'
  ]),
  _TileConfig(tier: 4, state: [3, 8, 1, 7, 0, 4, 2, 6, 5], optimal: 24, solution: [
    'up', 'left', 'down', 'right', 'right', 'up', 'left', 'down', 'right', 'down', 'left', 'left', 'up', 'up', 'right', 'down', 'down', 'left', 'up', 'up', 'right', 'down', 'right', 'down'
  ]),
];

const _goal = [1, 2, 3, 4, 5, 6, 7, 8, 0];

int _manhattan(List<int> s) {
  var total = 0;
  for (var i = 0; i < s.length; i++) {
    final v = s[i];
    if (v == 0) continue;
    final goalIdx = v - 1;
    total += (i ~/ 3 - goalIdx ~/ 3).abs() + (i % 3 - goalIdx % 3).abs();
  }
  return total;
}

bool _isSolved(List<int> s) {
  for (var i = 0; i < s.length; i++) {
    if (s[i] != _goal[i]) return false;
  }
  return true;
}

int _emptyIdx(List<int> s) => s.indexOf(0);

List<int>? _applyMove(List<int> s, int tileIdx) {
  final empty = _emptyIdx(s);
  final er = empty ~/ 3, ec = empty % 3;
  final tr = tileIdx ~/ 3, tc = tileIdx % 3;
  if ((er - tr).abs() + (ec - tc).abs() != 1) return null;
  final next = List<int>.from(s);
  next[empty] = next[tileIdx];
  next[tileIdx] = 0;
  return next;
}

List<int>? _applyDirection(List<int> s, String dir) {
  final empty = _emptyIdx(s);
  final er = empty ~/ 3, ec = empty % 3;
  late int nr, nc;
  switch (dir) {
    case 'up':
      nr = er + 1; nc = ec;
    case 'down':
      nr = er - 1; nc = ec;
    case 'left':
      nr = er; nc = ec + 1;
    case 'right':
      nr = er; nc = ec - 1;
    default:
      return null;
  }
  if (nr < 0 || nr > 2 || nc < 0 || nc > 2) return null;
  return _applyMove(s, nr * 3 + nc);
}

/// Persistence Task 1 — the sliding-tile puzzle with tiered telemetry.
class SlidingTile extends StatefulWidget {
  const SlidingTile({super.key, required this.onComplete, required this.onSkip});

  final void Function(PersistenceResult) onComplete;
  final VoidCallback onSkip;

  @override
  State<SlidingTile> createState() => _SlidingTileState();
}

enum _Phase { intro, warmup, playing, tierComplete }

class _SlidingTileState extends State<SlidingTile> {
  _Phase _phase = _Phase.intro;
  int _tierIdx = 0;
  List<int> _board = const [];
  int _moveCount = 0;
  int _hintsUsed = 0;
  int _reversals = 0;
  List<int> _manhattanLog = [];
  final List<TileTelemetry> _telemetry = [];
  int _lastMoveTime = 0;
  List<int> _lastBoard = const [];
  int _tierStartTime = 0;
  int? _firstMoveTime;
  bool _tierComplete = false;
  bool _firstMoveDone = false;

  _TileConfig get _config => _configs[_tierIdx];
  bool get _isWarmup => _tierIdx == 0;

  int get _now => DateTime.now().millisecondsSinceEpoch;

  void _startTier(int tierIdx) {
    final cfg = _configs[tierIdx];
    setState(() {
      _tierIdx = tierIdx;
      _board = List<int>.from(cfg.state);
      _moveCount = 0;
      _hintsUsed = 0;
      _reversals = 0;
      _manhattanLog = [_manhattan(cfg.state)];
      _lastMoveTime = 0;
      _lastBoard = const [];
      _tierStartTime = _now;
      _firstMoveTime = null;
      _firstMoveDone = false;
      _tierComplete = false;
      _phase = tierIdx == 0 ? _Phase.warmup : _Phase.playing;
    });
  }

  void _handleTileClick(int tileIdx) {
    if (_tierComplete) return;
    final next = _applyMove(_board, tileIdx);
    if (next == null) return;
    final now = _now;

    if (!_firstMoveDone) {
      _firstMoveTime = now - _tierStartTime;
      _firstMoveDone = true;
    }

    var newReversals = _reversals;
    if (_lastBoard.isNotEmpty && _lastMoveTime > 0) {
      final timeSinceLast = now - _lastMoveTime;
      var isReversal = true;
      for (var i = 0; i < next.length; i++) {
        if (next[i] != _lastBoard[i]) {
          isReversal = false;
          break;
        }
      }
      if (isReversal && timeSinceLast <= 3000) newReversals += 1;
    }

    final newMoveCount = _moveCount + 1;
    final newLog = List<int>.from(_manhattanLog);
    if (newMoveCount % 5 == 0) newLog.add(_manhattan(next));

    setState(() {
      _lastBoard = _board;
      _lastMoveTime = now;
      _board = next;
      _moveCount = newMoveCount;
      _reversals = newReversals;
      _manhattanLog = newLog;
    });

    if (_isSolved(next)) _handleSolved(newMoveCount, newReversals, newLog, _hintsUsed);
  }

  void _handleHint() {
    final cfg = _config;
    if (_moveCount >= cfg.solution.length) return;
    final nextDir = cfg.solution[_moveCount];
    final next = _applyDirection(_board, nextDir);
    if (next == null) return;
    final newHints = _hintsUsed + 1;
    final newMoveCount = _moveCount + 1;
    final newLog = List<int>.from(_manhattanLog);
    if (newMoveCount % 5 == 0) newLog.add(_manhattan(next));
    setState(() {
      _board = next;
      _moveCount = newMoveCount;
      _hintsUsed = newHints;
      _manhattanLog = newLog;
    });
    if (_isSolved(next)) _handleSolved(newMoveCount, _reversals, newLog, newHints);
  }

  void _handleSolved(int moves, int revs, List<int> log, int hints) {
    final cfg = _config;
    final finalLog = List<int>.from(log);
    if (finalLog.isEmpty || finalLog.last != 0) finalLog.add(0);
    final telemetry = TileTelemetry(
      tier: cfg.tier,
      totalMoves: moves,
      optimalMoves: cfg.optimal,
      ratio: moves / cfg.optimal,
      timeToFirstMove: _firstMoveTime ?? 0,
      reversals: revs,
      hintsUsed: hints,
      solved: true,
      quitTime: null,
      manhattanLog: finalLog,
      configIndex: _tierIdx,
    );
    _telemetry.add(telemetry);
    setState(() => _tierComplete = true);

    if (_isWarmup) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _startTier(1);
      });
      return;
    }

    final threshold = cfg.optimal * 2.0;
    final nextTierIdx = _tierIdx + 1;
    if (moves <= threshold && nextTierIdx < _configs.length) {
      setState(() => _phase = _Phase.tierComplete);
    } else {
      _finalize();
    }
  }

  void _handleQuit() {
    final cfg = _config;
    final finalLog = List<int>.from(_manhattanLog);
    final currentDist = _manhattan(_board);
    if (finalLog.isEmpty || finalLog.last != currentDist) finalLog.add(currentDist);
    _telemetry.add(TileTelemetry(
      tier: cfg.tier,
      totalMoves: _moveCount,
      optimalMoves: cfg.optimal,
      ratio: _moveCount / cfg.optimal,
      timeToFirstMove: _firstMoveTime ?? 0,
      reversals: _reversals,
      hintsUsed: _hintsUsed,
      solved: false,
      quitTime: _now - _tierStartTime,
      manhattanLog: finalLog,
      configIndex: _tierIdx,
    ));
    _finalize();
  }

  void _finalize() {
    widget.onComplete(_buildProfile(_telemetry));
  }

  PersistenceResult _buildProfile(List<TileTelemetry> all) {
    final measured = all.where((t) => t.tier >= 2).toList();
    final highestTier = all.map((t) => t.tier).fold<int>(0, (a, b) => a > b ? a : b);
    final counselorFlags = <String>[];
    final primary = measured.isNotEmpty ? measured.first : null;

    String profileLabel;
    if (primary == null) {
      profileLabel = 'low-frustration-early-quit';
    } else if (primary.solved && primary.hintsUsed > 0) {
      profileLabel = 'pragmatic-help-seeking';
    } else if (primary.solved && primary.hintsUsed == 0 && primary.ratio <= 2.0) {
      profileLabel = 'strategic-high-persistence';
    } else if (primary.solved && primary.hintsUsed == 0 && primary.ratio > 2.0) {
      profileLabel = 'high-persistence-low-efficiency';
    } else if (!primary.solved && primary.quitTime != null && primary.quitTime! < 30000) {
      profileLabel = 'low-frustration-early-quit';
    } else if (!primary.solved && primary.quitTime != null && primary.quitTime! >= 180000) {
      profileLabel = 'genuine-effort-late-quit';
    } else {
      profileLabel = 'mid-quit';
    }

    const effortRatingMap = {
      'strategic-high-persistence': 'You tend to stick with hard problems longer than most students.',
      'high-persistence-low-efficiency': 'You tend to stick with hard problems longer than most students.',
      'pragmatic-help-seeking': 'You persist well but use external support when stuck — which is healthy.',
      'low-frustration-early-quit':
          'You move on quickly when a problem feels unsolvable — which has both strengths and costs depending on the career.',
      'mid-quit': 'You engage with familiar problems confidently but step back from unfamiliar ones.',
      'genuine-effort-late-quit': 'You tend to stick with hard problems longer than most students.',
    };
    final effortRating = effortRatingMap[profileLabel]!;

    final avgFirstMove = measured.isEmpty
        ? 0.0
        : measured.fold<int>(0, (s, t) => s + t.timeToFirstMove) / measured.length;
    final totalReversals = measured.fold<int>(0, (s, t) => s + t.reversals);

    var manhattanPattern = 'oscillating';
    if (primary != null && primary.manhattanLog.length >= 2) {
      final log = primary.manhattanLog;
      final diffs = [for (var i = 1; i < log.length; i++) log[i] - log[i - 1]];
      final nInc = diffs.where((d) => d > 0).length;
      final nDec = diffs.where((d) => d < 0).length;
      if (nDec > nInc * 1.5) {
        manhattanPattern = 'decreasing';
      } else if (nInc > nDec * 1.5) {
        manhattanPattern = 'increasing';
      }
      var consecutiveInc = 0;
      for (final d in diffs) {
        if (d > 0) {
          consecutiveInc++;
          if (consecutiveInc >= 3) {
            counselorFlags.add(
                'Manhattan distance increased 3+ consecutive readings — student was lost, not just slow.');
            break;
          }
        } else {
          consecutiveInc = 0;
        }
      }
    }

    String approachStyle;
    if (totalReversals >= 3 && manhattanPattern == 'decreasing') {
      approachStyle = 'Systematic — you gather information before acting.';
    } else if (totalReversals >= 3 && manhattanPattern != 'decreasing') {
      approachStyle = 'Cautious — you prefer to understand the full picture before committing to any move.';
    } else if (avgFirstMove > 4000 && manhattanPattern == 'decreasing') {
      approachStyle = 'Systematic — you gather information before acting.';
    } else if (avgFirstMove > 4000 && manhattanPattern != 'decreasing') {
      approachStyle = 'Cautious — you prefer to understand the full picture before committing to any move.';
    } else {
      approachStyle = 'Intuitive — you act first and adjust from feedback.';
    }

    if (profileLabel == 'low-frustration-early-quit') {
      counselorFlags.add(
          'Early quit on Tier 2 within 30 seconds — low frustration tolerance flag. Review before recommending NEET/JEE/UPSC.');
    }
    if (profileLabel == 'genuine-effort-late-quit') {
      counselorFlags.add(
          'Late quit on Tier 2 after genuine effort (3+ minutes) — high persistence even without success.');
    }
    if (profileLabel == 'high-persistence-low-efficiency') {
      counselorFlags.add(
          'Solved but move ratio > 2× optimal — high effort, poor strategy. Student works hard but needs guidance on method.');
    }
    if (highestTier >= 4) {
      counselorFlags.add('Reached Tier 4 — strong persistence signal regardless of outcome.');
    }

    return PersistenceResult(
      highestTier: highestTier,
      tierTelemetry: all,
      effortRating: effortRating,
      approachStyle: approachStyle,
      counselorFlags: counselorFlags,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.intro:
        return _IntroCard(onSkip: widget.onSkip, onStart: () => _startTier(0));
      case _Phase.tierComplete:
        return _TierCompleteCard(
          onDone: _finalize,
          onNext: () => _startTier(_tierIdx + 1),
        );
      case _Phase.warmup:
      case _Phase.playing:
        return _boardView();
    }
  }

  Widget _boardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_isWarmup ? 'Warmup Round' : 'Puzzle — Level ${_config.tier - 1}',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        Text(_isWarmup ? 'Get familiar with the controls' : 'Arrange tiles 1–8 in order',
            style: const TextStyle(fontSize: 13, color: AppColors.neutral500)),
        const SizedBox(height: AppSpacing.s3),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (var idx = 0; idx < _board.length; idx++) _tile(idx),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        if (!_tierComplete)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _moveCount >= _config.solution.length ? null : _handleHint,
                  icon: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.amber600),
                  label: Text('Hint ($_hintsUsed used)', style: const TextStyle(color: AppColors.amber600)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: const BorderSide(color: AppColors.amber600),
                  ),
                ),
              ),
              if (!_isWarmup) ...[
                const SizedBox(width: AppSpacing.s1),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleQuit,
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                    child: const Text("I'm done with this", style: TextStyle(color: AppColors.neutral500)),
                  ),
                ),
              ],
            ],
          ),
        if (_tierComplete && !_isWarmup)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s2),
            decoration: BoxDecoration(
              color: AppColors.accent50,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.accent200),
            ),
            child: Text('Solved in $_moveCount moves ✓',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.accent700, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _tile(int idx) {
    final val = _board[idx];
    final empty = val == 0;
    return GestureDetector(
      onTap: empty || _tierComplete ? null : () => _handleTileClick(idx),
      child: Container(
        decoration: BoxDecoration(
          color: empty
              ? AppColors.neutral100
              : _tierComplete
                  ? AppColors.accent100
                  : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: empty
                ? AppColors.neutral300
                : _tierComplete
                    ? AppColors.accent400
                    : AppColors.neutral300,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(empty ? '' : '$val',
            style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _tierComplete ? AppColors.accent700 : AppColors.neutral900)),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.onSkip, required this.onStart});
  final VoidCallback onSkip;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(gradient: AppGradientsTeal.teal, borderRadius: BorderRadius.circular(AppRadius.md)),
          alignment: Alignment.center,
          child: const Text('🧩', style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(height: AppSpacing.s3),
        Text('One last game — this one is a bit different.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.s2),
        const Text('No time limit. No streak. Just a puzzle.\nSee how far you get.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.neutral600, height: 1.5)),
        const SizedBox(height: AppSpacing.s3),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s2),
          decoration: BoxDecoration(
            color: AppColors.accent50,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.accent200),
          ),
          child: const Text(
            'Slide the numbered tiles into order (1–8). Tap a tile next to the empty space to move it. A hint button is available if you get stuck.',
            style: TextStyle(fontSize: 13, color: AppColors.accent700),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Skip this game', style: TextStyle(color: AppColors.neutral500)),
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            Expanded(child: GradientButton(label: 'Start Puzzle', gradient: AppGradientsTeal.teal, onPressed: onStart)),
          ],
        ),
      ],
    );
  }
}

class _TierCompleteCard extends StatelessWidget {
  const _TierCompleteCard({required this.onDone, required this.onNext});
  final VoidCallback onDone;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(gradient: AppGradientsTeal.teal, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.white, size: 34),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text('Nice — you unlocked the next level.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.s1),
        const Text('This one is harder. Same rules — no time limit, no pressure.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral600)),
        const SizedBox(height: AppSpacing.s3),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDone,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text("I'm done"),
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            Expanded(child: GradientButton(label: 'Try the next level', gradient: AppGradientsTeal.teal, onPressed: onNext)),
          ],
        ),
      ],
    );
  }
}

/// Local teal gradient for the persistence puzzles (matches the web teal/cyan).
class AppGradientsTeal {
  AppGradientsTeal._();
  static const LinearGradient teal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent500, Color(0xFF0891B2)],
  );
}
