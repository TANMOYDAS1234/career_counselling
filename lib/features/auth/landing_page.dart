import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/i18n/translated_text.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/gradient_button.dart';
import 'auth_controller.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthed = ref.watch(authControllerProvider).isAuthenticated;
    final ctaTarget = isAuthed ? Routes.onboarding : Routes.signup;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(isAuthed: isAuthed)),
              SliverToBoxAdapter(child: _Hero(ctaTarget: ctaTarget)),
              const SliverToBoxAdapter(child: _FeaturePreview()),
              const SliverToBoxAdapter(child: _HowItWorks()),
              const SliverToBoxAdapter(child: _FeaturesOverview()),
              SliverToBoxAdapter(child: _CtaBand(ctaTarget: ctaTarget)),
              const SliverToBoxAdapter(child: _Footer()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isAuthed});
  final bool isAuthed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s2, AppSpacing.pageH, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BrandLogo(),
          if (!isAuthed)
            TextButton(
              onPressed: () => context.push(Routes.login),
              child: const TranslatedText('Login'),
            )
          else
            TextButton(
              onPressed: () => context.go(Routes.recommendations),
              child: const TranslatedText('Dashboard'),
            ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.ctaTarget});
  final String ctaTarget;

  @override
  Widget build(BuildContext context) {
    final headline = GoogleFonts.poppins(
      fontSize: 36,
      height: 1.15,
      fontWeight: FontWeight.w800,
      color: AppColors.neutral900,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s5, AppSpacing.pageH, AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const GradientPill(text: 'AI-Powered Career Guidance'),
          const SizedBox(height: AppSpacing.s3),
          TranslatedText('Discover Your Ideal', textAlign: TextAlign.center, style: headline),
          ShaderMask(
            shaderCallback: (b) => AppGradients.heroText.createShader(b),
            child: TranslatedText('Career Path with AI',
                textAlign: TextAlign.center, style: headline.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: AppSpacing.s2),
          const TranslatedText(
            'Get personalized career recommendations powered by advanced AI analysis of your interests, academic profile, and personality.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.neutral600, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.s3),
          GradientButton(
            label: 'Get Started Free',
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () => context.go(ctaTarget),
          ),
        ],
      ),
    );
  }
}

class _FeaturePreview extends StatelessWidget {
  const _FeaturePreview();

  static const _items = [
    (Icons.psychology_alt_rounded, 'AI Analysis', 'Advanced algorithms analyze your profile'),
    (Icons.track_changes_rounded, 'Personalized Roadmaps', '90-day plans tailored to your goals'),
    (Icons.workspace_premium_rounded, 'Expert Insights', 'Learn from industry professionals'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: Column(
        children: [
          for (final (icon, title, desc) in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              child: AppCard(
                child: Row(
                  children: [
                    _IconTile(icon: icon),
                    const SizedBox(width: AppSpacing.s2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          TranslatedText(desc, style: const TextStyle(color: AppColors.neutral600)),
                        ],
                      ),
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

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    ('1', 'Complete Assessment', 'Answer questions about your education, interests, and skills.', Icons.school_rounded),
    ('2', 'AI-Powered Analysis', 'Our AI engine matches you with the best-fit career paths.', Icons.psychology_alt_rounded),
    ('3', 'Get Your Roadmap', 'Receive detailed roadmaps, skills, institutes, and salary insights.', Icons.track_changes_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s5, AppSpacing.pageH, AppSpacing.s5),
      child: Column(
        children: [
          TranslatedText('How It Works', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const TranslatedText('Your personalized career journey in 3 simple steps',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.s3),
          for (final (step, title, desc, icon) in _steps)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryButton,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: TranslatedText(step,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Row(
                      children: [
                        Icon(icon, color: AppColors.neutral700),
                        const SizedBox(width: 8),
                        Expanded(child: TranslatedText(title, style: Theme.of(context).textTheme.titleMedium)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TranslatedText(desc, style: const TextStyle(color: AppColors.neutral600, height: 1.5)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturesOverview extends StatelessWidget {
  const _FeaturesOverview();

  static const _items = [
    (Icons.track_changes_rounded, 'Career Recommendations', 'AI suggestions for core, specialized & interdisciplinary roles'),
    (Icons.menu_book_rounded, 'Learning Roadmaps', '90-day plans with actionable tasks and progress tracking'),
    (Icons.bar_chart_rounded, 'Salary Insights', 'Detailed salary progression and city-wise comparisons'),
    (Icons.workspace_premium_rounded, 'Top Institutes', 'Government, private, and online institutions'),
    (Icons.lightbulb_rounded, 'Skills Guidance', 'Must-have, core, and bonus skills with resources'),
    (Icons.groups_rounded, 'Industry Experts', 'Advice from professionals in your target career'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s5, AppSpacing.pageH, AppSpacing.s4),
      child: Column(
        children: [
          TranslatedText('Everything You Need', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const TranslatedText('Comprehensive career guidance platform',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.s3),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.s2,
              crossAxisSpacing: AppSpacing.s2,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, i) {
              final (icon, title, desc) = _items[i];
              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconTile(icon: icon, size: 44),
                    const SizedBox(height: AppSpacing.s1),
                    TranslatedText(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: TranslatedText(desc,
                          style: const TextStyle(color: AppColors.neutral600, fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CtaBand extends StatelessWidget {
  const _CtaBand({required this.ctaTarget});
  final String ctaTarget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageH),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            TranslatedText('Ready to Discover Your Career Path?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.s1),
            TranslatedText('Join thousands of students who found their perfect career with EduBot',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(height: AppSpacing.s3),
            GradientButton(
              label: 'Get Started Free',
              gradient: const LinearGradient(colors: [Colors.white, Colors.white]),
              labelColor: AppColors.secondary600,
              onPressed: () => context.go(ctaTarget),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral900,
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        children: [
          const BrandLogo(onLight: false),
          const SizedBox(height: AppSpacing.s1),
          const TranslatedText('AI-powered career guidance for students',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral400)),
          const SizedBox(height: AppSpacing.s3),
          TranslatedText('© 2026 EduBot. All rights reserved.',
              style: TextStyle(color: AppColors.neutral400, fontSize: 12)),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, this.size = 52});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.softPill,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: AppColors.primary600, size: size * 0.5),
    );
  }
}
