import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'language_controller.dart';

/// A compact language selector. Use [compact] for an icon+code pill (app bar)
/// or the default for a full row of selectable chips (settings).
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    if (compact) {
      return PopupMenuButton<String>(
        tooltip: 'Language',
        onSelected: (code) => ref.read(languageProvider.notifier).setLanguage(code),
        itemBuilder: (_) => [
          for (final entry in kSupportedLanguages.entries)
            PopupMenuItem(
              value: entry.key,
              child: Row(
                children: [
                  if (entry.key == current)
                    const Icon(Icons.check_rounded, size: 18, color: AppColors.primary600)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(entry.value),
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.primary200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 16, color: AppColors.primary700),
              const SizedBox(width: 6),
              Text(current.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in kSupportedLanguages.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s1),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () => ref.read(languageProvider.notifier).setLanguage(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 14),
                decoration: BoxDecoration(
                  color: entry.key == current ? AppColors.primary50 : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: entry.key == current ? AppColors.primary300 : AppColors.neutral200,
                    width: entry.key == current ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(entry.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: entry.key == current ? FontWeight.w700 : FontWeight.w500,
                          color: entry.key == current ? AppColors.primary700 : AppColors.neutral800,
                        )),
                    const Spacer(),
                    if (entry.key == current)
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary600, size: 22),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
