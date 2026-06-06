import 'dart:async';

import 'package:flutter/material.dart';

import '../i18n/translated_text.dart';
import '../theme/app_colors.dart';

/// Cycles through [messages] with a soft fade, so long AI / PDF waits feel
/// alive and "thinking" instead of a static label.
class RotatingStatus extends StatefulWidget {
  const RotatingStatus({
    super.key,
    required this.messages,
    this.interval = const Duration(milliseconds: 2200),
    this.style,
  });

  final List<String> messages;
  final Duration interval;
  final TextStyle? style;

  @override
  State<RotatingStatus> createState() => _RotatingStatusState();
}

class _RotatingStatusState extends State<RotatingStatus> {
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.messages.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        if (mounted) setState(() => _i = (_i + 1) % widget.messages.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: TranslatedText(
        widget.messages[_i],
        key: ValueKey(_i),
        textAlign: TextAlign.center,
        style: widget.style ?? const TextStyle(color: AppColors.neutral600, height: 1.5),
      ),
    );
  }
}

/// Shared "thinking" lines for the report-generation wait.
const kReportThinkingMessages = [
  'Reading your assessment…',
  'Matching you with real Indian institutes…',
  'Crunching salary & job-market data…',
  'Finding scholarships and entrance exams…',
  'Mapping your step-by-step pathway…',
  'Polishing your personalized report…',
];

/// Shared "thinking" lines for the PDF export wait.
const kPdfThinkingMessages = [
  'Laying out your report…',
  'Rendering charts and tables…',
  'Adding fonts and styling…',
  'Formatting pages for print…',
  'Almost ready…',
];
