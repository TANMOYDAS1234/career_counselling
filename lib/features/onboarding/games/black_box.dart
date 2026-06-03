import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/i18n/translated_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'games_models.dart';

const _violet600 = Color(0xFF7C3AED);
const _violet500 = Color(0xFF8B5CF6);
const _violet200 = Color(0xFFDDD6FE);
const _violet50 = Color(0xFFF5F3FF);
const _violet700 = Color(0xFF6D28D9);

int _bbRule(int n) => n * 3 - 1;
const _bbMaxGuesses = 3;
bool _isStrategicInput(int n) => n <= 10 || n % 10 == 0;

/// Persistence Task 3 — discover the hidden rule (output = input × 3 − 1).
class BlackBox extends StatefulWidget {
  const BlackBox({super.key, required this.onComplete, required this.onSkip});

  final void Function(BlackBoxResult) onComplete;
  final VoidCallback onSkip;

  @override
  State<BlackBox> createState() => _BlackBoxState();
}

class _BlackBoxState extends State<BlackBox> {
  final _input = TextEditingController();
  final _guessM = TextEditingController();
  final _guessS = TextEditingController();
  final _tests = <({int input, int output})>[];
  int _guessCount = 0;
  final List<List<double>> _wrongGuesses = [];
  bool _solved = false;
  String _guessError = '';
  bool _showLastGuessPrompt = false;

  @override
  void dispose() {
    _input.dispose();
    _guessM.dispose();
    _guessS.dispose();
    super.dispose();
  }

  void _handleTest() {
    final n = int.tryParse(_input.text);
    if (n == null || n < 1 || n > 999) return;
    setState(() {
      _tests.add((input: n, output: _bbRule(n)));
      _input.clear();
    });
  }

  void _handleGuess() {
    final m = double.tryParse(_guessM.text);
    final s = double.tryParse(_guessS.text);
    if (m == null || s == null) {
      setState(() => _guessError = 'Enter both numbers.');
      return;
    }
    final newCount = _guessCount + 1;
    if (m == 3 && s == 1) {
      setState(() {
        _guessCount = newCount;
        _solved = true;
        _guessError = '';
      });
      _finalize(true, false, newCount, _wrongGuesses);
      return;
    }
    _wrongGuesses.add([m, s]);
    setState(() {
      _guessCount = newCount;
      _guessM.clear();
      _guessS.clear();
    });
    if (newCount >= _bbMaxGuesses) {
      _finalize(false, false, newCount, _wrongGuesses);
    } else if (newCount == _bbMaxGuesses - 1) {
      setState(() {
        _showLastGuessPrompt = true;
        _guessError = '';
      });
    } else {
      final rem = _bbMaxGuesses - newCount;
      setState(() => _guessError = 'Not quite. $rem guess${rem == 1 ? '' : 'es'} remaining.');
    }
  }

  void _finalize(bool didSolve, bool abandoned, int guesses, List<List<double>> wrong) {
    final strategicCount = _tests.where((t) => _isStrategicInput(t.input)).length;
    var converging = false;
    if (wrong.length >= 2) {
      final distances = wrong.map((g) => (g[0] - 3).abs() + (g[1] - 1).abs()).toList();
      converging = distances.last < distances.first;
    }

    var approachLabel = 'intuitive';
    String? counselorFlag;

    if (!didSolve && abandoned) {
      approachLabel = 'fear-of-failure';
      counselorFlag =
          'Student had one guess remaining but chose not to use it — fear of failure / exam anxiety indicator. Counselor should explore before high-stakes exam path commitment.';
    } else if (strategicCount >= 3 && converging && didSolve) {
      approachLabel = 'scientific-reasoning';
    } else if (strategicCount >= 3 && converging && !didSolve) {
      approachLabel = 'observational-weak-synthesis';
    } else if (strategicCount >= 3 && !converging) {
      approachLabel = 'observational-weak-synthesis';
    } else if (strategicCount < 2 && didSolve && guesses == 1) {
      approachLabel = 'intuitive-lucky';
    } else if (strategicCount < 2 && didSolve) {
      approachLabel = 'intuitive';
    } else if (!didSolve && guesses == _bbMaxGuesses) {
      approachLabel = 'observational-weak-synthesis';
    }

    widget.onComplete(BlackBoxResult(
      inputsTested: _tests.length,
      strategicInputs: strategicCount,
      guessCount: guesses,
      wrongGuesses: wrong,
      guessesConvergingToAnswer: converging,
      solved: didSolve,
      abandonedLastGuess: abandoned,
      approachLabel: approachLabel,
      counselorFlag: counselorFlag,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _bbMaxGuesses - _guessCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText('The Black Box',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
        const TranslatedText('This box transforms numbers by a hidden rule. Test inputs, figure out the rule, then guess it.',
            style: TextStyle(fontSize: 13, color: AppColors.neutral500)),
        const SizedBox(height: AppSpacing.s2),

        // Test the box
        Container(
          padding: const EdgeInsets.all(AppSpacing.s2),
          decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(AppRadius.sm)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TranslatedText('TEST THE BOX',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral500, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: (_) => _handleTest(),
                      decoration: const InputDecoration(hintText: 'Enter a number', counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _handleTest,
                    style: FilledButton.styleFrom(backgroundColor: _violet600),
                    child: const TranslatedText('Try'),
                  ),
                ],
              ),
              if (_tests.isNotEmpty) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final t in _tests)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TranslatedText('${t.input}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontFamily: 'monospace', color: AppColors.neutral600)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: TranslatedText('→', style: TextStyle(color: AppColors.neutral400)),
                                ),
                                TranslatedText('${t.output}',
                                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: _violet700)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s2),

        // Guess the rule
        Container(
          padding: const EdgeInsets.all(AppSpacing.s2),
          decoration: BoxDecoration(
            color: _violet50,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: _violet200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText('GUESS THE RULE — $remaining guess${remaining == 1 ? '' : 'es'} remaining',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _violet700, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              const TranslatedText('output = input × ?  −  ?',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
              const SizedBox(height: 10),
              if (_showLastGuessPrompt)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText('You have one guess left. Do you want to use it?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.amber600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => setState(() => _showLastGuessPrompt = false),
                            style: FilledButton.styleFrom(backgroundColor: _violet600),
                            child: const TranslatedText('Make my last guess'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _finalize(false, true, _guessCount, _wrongGuesses),
                            child: const TranslatedText("I'm done", style: TextStyle(color: AppColors.neutral500)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else if (!_solved && _guessCount < _bbMaxGuesses)
                Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const TranslatedText('input ×', style: TextStyle(color: AppColors.neutral500)),
                    _miniInput(_guessM),
                    const TranslatedText('−', style: TextStyle(color: AppColors.neutral500)),
                    _miniInput(_guessS),
                    FilledButton(
                      onPressed: _handleGuess,
                      style: FilledButton.styleFrom(backgroundColor: _violet600),
                      child: const TranslatedText('Guess'),
                    ),
                  ],
                )
              else if (_solved)
                const TranslatedText('✓ Correct! Rule: output = input × 3 − 1',
                    style: TextStyle(color: AppColors.emerald600, fontWeight: FontWeight.w700))
              else
                const TranslatedText('No guesses remaining.',
                    style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.w700)),
              if (_guessError.isNotEmpty) ...[
                const SizedBox(height: 6),
                TranslatedText(_guessError, style: const TextStyle(fontSize: 13, color: AppColors.destructive)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onSkip,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                child: const TranslatedText('Skip', style: TextStyle(color: AppColors.neutral400)),
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _finalize(false, false, _guessCount, _wrongGuesses),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                child: const TranslatedText("I'm done", style: TextStyle(color: AppColors.neutral500)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniInput(TextEditingController c) {
    return SizedBox(
      width: 56,
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '?',
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: _violet200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: _violet500, width: 2),
          ),
        ),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
