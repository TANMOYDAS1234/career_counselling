import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Code → human-readable label maps for the Mindset Report,
/// ported 1:1 from the web `career-report.tsx`.
abstract class ReportLabels {
  static const Map<String, String> whyHere = {
    'no-idea': 'No idea what to do after Class 12',
    'validate': 'Has a plan and wants to validate it',
    'disagree': 'Family disagreement about career',
    'explore': 'Wants to explore options before deciding',
  };

  static const Map<String, String> vision = {
    'conventional': 'Expert / specialist work (uniform or lab coat)',
    'enterprising': 'Leadership / decision-making',
    'artistic': 'Creating — design, writing, performance',
    'entrepreneurial': 'Running own venture',
  };

  static const Map<String, String> freeSunday = {
    'puzzle': 'Solving puzzles / strategy games',
    'friends': 'Hanging out and meeting people',
    'create': 'Making things — art, music, writing',
    'build': 'Fixing or building with hands',
    'organize': 'Organizing notes, room, life',
    'read': 'Reading about how the world works',
  };

  static const Map<String, String> groupRole = {
    'plan': 'Planner — divides work and leads strategy',
    'research': 'Researcher — digs into analysis',
    'present': 'Presenter — shapes the final output',
    'motivate': 'Motivator — keeps the team energized',
    'execute': 'Executor — builds and delivers',
  };

  static const Map<String, String> jobBothers = {
    'repetitive': 'Repeating the same task every day',
    'decisions': 'High-stakes decisions and blame',
    'alone': 'Working alone without human contact',
    'no-result': 'Not seeing a clear result of work',
    'strict-rules': 'Strict rules and procedures',
  };

  static const Map<String, String> studyExp = {
    'flow': 'Loses track of time — deep flow state',
    'work': 'Does well but it still feels like work',
    'class-only': 'Enjoys class but struggles to study alone',
    'videos': 'Prefers videos and discussion over textbooks',
  };

  static const Map<String, String> extVal = {
    'agree': 'Yes, and agrees with it',
    'unsure': 'Yes, but unsure',
    'disagree': 'Yes, but does not want to do it',
    'no': 'No external validation received',
  };

  static const Map<String, String> budget = {
    'clear-budget': 'Yes — clear budget discussed',
    'depends': 'Yes — depends on the course',
    'not-really': 'Not really discussed',
    'no-money-factor': 'Prefers not to factor money in',
  };

  static const Map<String, String> values = {
    'earning': 'Earning well',
    'interest': 'Doing genuinely interesting work',
    'family-pride': 'Family pride',
    'stability': 'Stability and security',
    'impact': 'Making a real impact',
  };

  static const Map<String, String> planning = {
    'clear-plan': 'Prefers a clear plan and follows it',
    'options': 'Prefers options and figures it out as they go',
    'others': 'Wants to know what worked for others',
    'try-things': 'Learns by trying things',
  };

  static const Map<String, String> stress = {
    'power-through': 'Powers through and finishes',
    'take-break': 'Takes a break and comes back',
    'talk': 'Talks to someone about it',
    'procrastinate': 'Gets overwhelmed and procrastinates',
  };

  static const Map<String, String> surprise = {
    'excited': 'Excited to explore it',
    'skeptical': 'Skeptical but curious',
    'wrong': 'Feels the system got it wrong',
    'counselor': 'Wants to talk to a counselor',
  };

  // ── Aptitude score → label / colors ──────────────────────────────────────
  static String aptitudeLabel(int? score) {
    if (score == null) return 'Not completed';
    if (score >= 7) return 'Exceptional';
    if (score >= 5) return 'Strong';
    if (score >= 3) return 'Moderate';
    return 'Developing';
  }

  static Color aptitudeBg(int? score) {
    if (score == null) return AppColors.neutral100;
    if (score >= 7) return AppColors.emerald100;
    if (score >= 5) return AppColors.primary100;
    if (score >= 3) return AppColors.amber100;
    return AppColors.destructiveBg;
  }

  static Color aptitudeFg(int? score) {
    if (score == null) return AppColors.neutral500;
    if (score >= 7) return AppColors.emerald600;
    if (score >= 5) return AppColors.primary700;
    if (score >= 3) return AppColors.amber600;
    return AppColors.destructive;
  }
}
