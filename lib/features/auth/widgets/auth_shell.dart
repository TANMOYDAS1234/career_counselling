import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/brand.dart';

/// Mobile adaptation of the web auth pages: the desktop left "illustration"
/// panel becomes a gradient hero band on top, with the form card beneath it.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.panelTitle,
    required this.panelSubtitle,
    required this.benefits,
    required this.formTitle,
    required this.formSubtitle,
    required this.form,
    required this.footer,
  });

  final String panelTitle;
  final String panelSubtitle;
  final List<String> benefits;
  final String formTitle;
  final String formSubtitle;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _HeroBand(title: panelTitle, subtitle: panelSubtitle, benefits: benefits),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.pageH),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formTitle, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(formSubtitle, style: const TextStyle(color: AppColors.neutral600)),
                        const SizedBox(height: AppSpacing.s3),
                        form,
                        const SizedBox(height: AppSpacing.s2),
                        footer,
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(Routes.landing),
                  child: const Text('← Back to Home'),
                ),
                const SizedBox(height: AppSpacing.s3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBand extends StatelessWidget {
  const _HeroBand({required this.title, required this.subtitle, required this.benefits});

  final String title;
  final String subtitle;
  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s4, AppSpacing.pageH, AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLogo(onLight: false),
          const SizedBox(height: AppSpacing.s3),
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.s1),
          Text(subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 15, height: 1.5)),
          const SizedBox(height: AppSpacing.s3),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.s1),
                  Expanded(
                    child: Text(b, style: TextStyle(color: Colors.white.withValues(alpha: 0.92))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Inline error banner matching the web `bg-red-50 border-red-200` style.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.destructiveBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.destructiveBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.destructive, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.destructive, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
