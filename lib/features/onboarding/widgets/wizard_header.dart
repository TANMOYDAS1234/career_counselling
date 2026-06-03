import 'package:flutter/material.dart';

import '../../../core/i18n/translated_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';

/// Top progress bar + step label for the assessment wizard.
class WizardHeader extends StatelessWidget {
  const WizardHeader({
    super.key,
    required this.progress,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final double progress; // 0..1
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s2, AppSpacing.pageH, AppSpacing.s1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.neutral600,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (onBack != null) const SizedBox(width: AppSpacing.s1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary700)),
                    if (subtitle != null)
                      TranslatedText(subtitle!,
                          style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                  ],
                ),
              ),
              TranslatedText('${(progress * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary600)),
            ],
          ),
          const SizedBox(height: AppSpacing.s1),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(height: 8, color: AppColors.neutral100),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    height: 8,
                    width: constraints.maxWidth * progress.clamp(0, 1),
                    decoration: const BoxDecoration(gradient: AppGradients.primaryButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
