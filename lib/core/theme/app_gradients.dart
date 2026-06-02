import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradients ported from the web `.gradient-*` utilities and the common
/// Tailwind `from-indigo-600 to-purple-600` button gradient.
class AppGradients {
  AppGradients._();

  static const Alignment _begin = Alignment.topLeft; // ~135deg
  static const Alignment _end = Alignment.bottomRight;

  /// `.gradient-primary` — indigo-500 → indigo-600.
  static const LinearGradient primary = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [AppColors.primary500, AppColors.primary600],
  );

  /// Most CTA buttons: `bg-gradient-to-r from-indigo-600 to-purple-600`.
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary600, AppColors.secondary600],
  );

  /// `.gradient-secondary` — purple-500 → purple-600.
  static const LinearGradient secondary = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [AppColors.secondary500, AppColors.secondary600],
  );

  /// `.gradient-accent` — teal-500 → teal-600.
  static const LinearGradient accent = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [AppColors.accent500, AppColors.accent600],
  );

  /// Hero text gradient: indigo-600 → purple-600 → teal-500.
  static const LinearGradient heroText = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary600, AppColors.secondary600, AppColors.accent500],
  );

  /// Soft tinted pill: from-indigo-100 to-teal-100.
  static const LinearGradient softPill = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary100, AppColors.accent100],
  );
}
