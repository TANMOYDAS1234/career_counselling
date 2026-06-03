import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/i18n/language_switcher.dart';
import '../../core/i18n/translated_text.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/edubot_app_bar.dart';
import '../auth/auth_controller.dart';

/// `/settings` — language preference + account shortcuts.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: const EduBotAppBar(),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s3, AppSpacing.pageH, AppSpacing.s5),
            children: [
              Text('Settings',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
              const SizedBox(height: AppSpacing.s3),

              // ── Language ──────────────────────────────────────────────
              const _SectionLabel(icon: Icons.language_rounded, label: 'Language'),
              const SizedBox(height: AppSpacing.s1),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    TranslatedText('Choose your preferred language',
                        style: TextStyle(fontSize: 13, color: AppColors.neutral500)),
                    SizedBox(height: AppSpacing.s2),
                    LanguageSwitcher(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s3),

              // ── Account ───────────────────────────────────────────────
              const _SectionLabel(icon: Icons.person_outline_rounded, label: 'Account'),
              const SizedBox(height: AppSpacing.s1),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _Tile(
                      icon: Icons.manage_accounts_outlined,
                      title: 'Profile',
                      subtitle: user?.email ?? '',
                      onTap: () => context.push(Routes.profile),
                    ),
                    const Divider(height: 1, color: AppColors.neutral100),
                    _Tile(
                      icon: Icons.assessment_outlined,
                      title: 'Mindset Report',
                      subtitle: 'View your assessment analysis',
                      onTap: () => context.push(Routes.careerReport),
                    ),
                    const Divider(height: 1, color: AppColors.neutral100),
                    _Tile(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      titleColor: AppColors.destructive,
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) context.go(Routes.landing);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              const Center(
                child: Text('EduBot • v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppColors.neutral400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary600),
        const SizedBox(width: 8),
        TranslatedText(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor = AppColors.neutral900,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: titleColor == AppColors.destructive ? AppColors.destructive : AppColors.primary600),
      title: TranslatedText(title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: titleColor)),
      subtitle: (subtitle != null && subtitle!.isNotEmpty)
          ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.neutral500))
          : null,
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
    );
  }
}
