import 'package:flutter/material.dart';

import '../../../core/i18n/translated_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// A selectable answer card: icon tile + label, with selected styling that
/// matches the web (indigo-600 border + indigo-50 fill, filled icon tile).
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.rank,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  /// When set (multi-select ranking), shows this number instead of the icon.
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || selected ? 1 : 0.5,
      child: Material(
        color: selected ? AppColors.primary50 : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.primary600 : AppColors.neutral200,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary600 : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: rank != null
                      ? Text('$rank',
                          style: const TextStyle(
                              color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 18))
                      : Icon(icon,
                          size: 22, color: selected ? AppColors.white : AppColors.neutral600),
                ),
                const SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: TranslatedText(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.primary900 : AppColors.neutral800,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary600, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact chip used in the subject grid (Q8/Q9).
class ChoiceChipCard extends StatelessWidget {
  const ChoiceChipCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.color = AppColors.primary600,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || selected ? 1 : 0.5,
      child: Material(
        color: selected ? color.withValues(alpha: 0.08) : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? color : AppColors.neutral200,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TranslatedText(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : AppColors.neutral700,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle_rounded, size: 16, color: color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
