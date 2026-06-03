import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import 'games_models.dart';

const _cgColors = ['🔴', '🟡', '🔵', '🟢'];
const _cgSymbols = ['A', 'B', 'C', 'D'];
// Row0:(1,A)(2,B)(3,C)(4,D) Row1:(2,C)(1,D)(4,A)(3,B) Row2:(3,D)(4,C)(1,B)(2,A) Row3:(4,B)(3,A)(2,D)(1,C)
const _cgSolution = [1, 6, 11, 16, 7, 4, 13, 10, 12, 15, 2, 5, 14, 9, 8, 3];
const _cgPrefilled = {1, 2, 3, 4, 6, 8, 9, 11, 13, 15};

const _violet600 = Color(0xFF7C3AED);
const _violet500 = Color(0xFF8B5CF6);
const _violet200 = Color(0xFFDDD6FE);
const _violet50 = Color(0xFFF5F3FF);
const _violet700 = Color(0xFF6D28D9);

int _mostConstrainedEmptyCell() {
  final emptyCells = [for (var i = 0; i < _cgSolution.length; i++) if (!_cgPrefilled.contains(i)) i];
  var minOptions = 1 << 30;
  var best = emptyCells.first;
  for (final idx in emptyCells) {
    final row = idx ~/ 4, col = idx % 4;
    final usedInRow = <int>{}, usedInCol = <int>{};
    for (var c = 0; c < 4; c++) {
      if (_cgPrefilled.contains(row * 4 + c)) usedInRow.add(_cgSolution[row * 4 + c]);
    }
    for (var r = 0; r < 4; r++) {
      if (_cgPrefilled.contains(r * 4 + col)) usedInCol.add(_cgSolution[r * 4 + col]);
    }
    var options = 0;
    for (var v = 1; v <= 16; v++) {
      if (!usedInRow.contains(v) && !usedInCol.contains(v)) options++;
    }
    if (options < minOptions) {
      minOptions = options;
      best = idx;
    }
  }
  return best;
}

final _cgEasyEntry = _mostConstrainedEmptyCell();

/// Persistence Task 2 — the constraint grid (4×4 Latin-square style).
class ConstraintGrid extends StatefulWidget {
  const ConstraintGrid({super.key, required this.onComplete, required this.onSkip});

  final void Function(ConstraintGridResult) onComplete;
  final VoidCallback onSkip;

  @override
  State<ConstraintGrid> createState() => _ConstraintGridState();
}

class _ConstraintGridState extends State<ConstraintGrid> {
  bool _started = false;
  final List<int?> _grid = [for (var i = 0; i < _cgSolution.length; i++) _cgPrefilled.contains(i) ? _cgSolution[i] : null];
  int? _selected;
  int _mistakes = 0;
  int _mistakesUndone = 0;
  bool _hintUsed = false;
  int? _firstInteractionTime;
  int? _firstCellTouched;
  bool _shutdownFlag = false;
  int _cgStart = 0;
  Timer? _timer;

  int get _now => DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleStart() {
    setState(() => _started = true);
    _cgStart = _now;
    _timer = Timer(const Duration(seconds: 30), () {
      if (_firstInteractionTime == null && mounted) setState(() => _shutdownFlag = true);
    });
  }

  void _handleCellClick(int idx) {
    if (_cgPrefilled.contains(idx)) return;
    if (_firstInteractionTime == null) {
      _firstInteractionTime = _now - _cgStart;
      _timer?.cancel();
    }
    _firstCellTouched ??= idx;
    setState(() => _selected = idx == _selected ? null : idx);
  }

  void _handleValueSelect(int val) {
    final sel = _selected;
    if (sel == null) return;
    final prev = _grid[sel];
    if (prev != null && prev != _cgSolution[sel]) _mistakesUndone++;
    if (val != _cgSolution[sel]) _mistakes++;
    setState(() {
      _grid[sel] = val;
      _selected = null;
    });
    if (_complete(_grid)) _finalize(_grid, false);
  }

  void _handleHint() {
    final sel = _selected;
    if (sel == null) return;
    setState(() {
      _hintUsed = true;
      _grid[sel] = _cgSolution[sel];
      _selected = null;
    });
    if (_complete(_grid)) _finalize(_grid, false);
  }

  bool _complete(List<int?> g) {
    for (var i = 0; i < g.length; i++) {
      if (g[i] != _cgSolution[i]) return false;
    }
    return true;
  }

  void _finalize(List<int?> finalGrid, bool shutdown) {
    _timer?.cancel();
    final scanTime = _firstInteractionTime ?? (_now - _cgStart);
    final solved = _complete(finalGrid);
    final foundEasy = _firstCellTouched == _cgEasyEntry;
    var approachLabel = 'intuitive-adaptive';
    String? counselorFlag;

    if (shutdown || _firstInteractionTime == null) {
      approachLabel = 'complexity-shutdown';
      counselorFlag =
          'Student looked at constraint grid 30s+ without attempting — anxiety of not knowing where to start. High-priority counselor flag before committing to any ambiguous-problem path.';
    } else if (scanTime < 2000 && _hintUsed) {
      approachLabel = 'low-ambiguity-tolerance';
      counselorFlag =
          'Immediate hint use (scan < 2s) — low tolerance for ambiguity. Better suited to clearly defined roles with step-by-step processes.';
    } else if (scanTime > 5000 && foundEasy) {
      approachLabel = 'systematic-analytical';
    } else if (scanTime > 5000 && !foundEasy) {
      approachLabel = 'cautious';
    } else if (_mistakes > 0 && _mistakesUndone >= (_mistakes * 0.5).ceil()) {
      approachLabel = 'intuitive-adaptive';
    }

    widget.onComplete(ConstraintGridResult(
      scanTimeMs: scanTime,
      foundEasyEntryFirst: foundEasy,
      mistakesMade: _mistakes,
      mistakesUndone: _mistakesUndone,
      hintUsed: _hintUsed,
      solved: solved,
      shutdownWithoutAttempt: shutdown || _firstInteractionTime == null,
      approachLabel: approachLabel,
      counselorFlag: counselorFlag,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return _intro();

    final emptyCount = _cgSolution.length - _cgPrefilled.length;
    final filled = [for (var i = 0; i < _grid.length; i++) if (!_cgPrefilled.contains(i) && _grid[i] != null) i].length;
    final progress = ((filled / emptyCount) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Constraint Grid',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                  const Text('Each row and column must have each color and letter exactly once',
                      style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                ],
              ),
            ),
            Column(
              children: [
                Text('$progress%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _violet600)),
                const Text('filled', style: TextStyle(fontSize: 11, color: AppColors.neutral500)),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [for (var idx = 0; idx < _grid.length; idx++) _cell(idx)],
            ),
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: AppSpacing.s2),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s1),
            decoration: BoxDecoration(
              color: _violet50,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: _violet200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select color + letter:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _violet700)),
                const SizedBox(height: 6),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.4,
                  children: [
                    for (var v = 1; v <= 16; v++)
                      GestureDetector(
                        onTap: () => _handleValueSelect(v),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: _violet200, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_cgColors[(v / 4).ceil() - 1], style: const TextStyle(fontSize: 13)),
                              Text(_cgSymbols[(v - 1) % 4],
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.s2),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (_selected == null || _hintUsed) ? null : _handleHint,
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.amber600),
                label: Text(_hintUsed ? 'Hint used' : 'Hint', style: const TextStyle(color: AppColors.amber600)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: const BorderSide(color: AppColors.amber600),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _finalize(_grid, _shutdownFlag),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                child: const Text("I'm done", style: TextStyle(color: AppColors.neutral500)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cell(int idx) {
    final val = _grid[idx];
    final isPrefilled = _cgPrefilled.contains(idx);
    final isSelected = _selected == idx;
    final isWrong = val != null && !isPrefilled && val != _cgSolution[idx];
    final color = val != null ? _cgColors[(val / 4).ceil() - 1] : null;
    final symbol = val != null ? _cgSymbols[(val - 1) % 4] : null;
    Color border;
    Color bg;
    if (isPrefilled) {
      border = AppColors.neutral300;
      bg = AppColors.neutral100;
    } else if (isSelected) {
      border = _violet500;
      bg = _violet50;
    } else if (isWrong) {
      border = const Color(0xFFF87171);
      bg = const Color(0xFFFEF2F2);
    } else if (val != null) {
      border = const Color(0xFF4ADE80);
      bg = const Color(0xFFF0FDF4);
    } else {
      border = AppColors.neutral300;
      bg = AppColors.white;
    }
    return GestureDetector(
      onTap: isPrefilled ? null : () => _handleCellClick(idx),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: val != null
              ? [
                  Text(color!, style: const TextStyle(fontSize: 16)),
                  Text(symbol!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral700)),
                ]
              : const [Text('?', style: TextStyle(fontSize: 18, color: AppColors.neutral300))],
        ),
      ),
    );
  }

  Widget _intro() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_violet500, _violet600]),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: const Text('🧩', style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(height: AppSpacing.s3),
        Text('Constraint Grid',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.s2),
        const Text(
          'A 4×4 grid of colored symbols. Each row and each column must contain each color and each letter exactly once. Some cells are already filled. Find the right cells to complete it.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.neutral600, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.s3),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s2),
          decoration: BoxDecoration(
            color: _violet50,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: _violet200),
          ),
          child: const Text(
            'Tap an empty cell, then choose the color + letter that fits. A hint is available if you get stuck.',
            style: TextStyle(fontSize: 13, color: _violet700),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onSkip,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Skip', style: TextStyle(color: AppColors.neutral500)),
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            Expanded(
              child: GradientButton(
                label: 'Start Puzzle',
                gradient: const LinearGradient(colors: [_violet600, _violet600]),
                onPressed: _handleStart,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
