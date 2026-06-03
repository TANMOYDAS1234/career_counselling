import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../auth/auth_controller.dart';
import 'report_labels.dart';

/// Fetches the full mindset report for the current user.
final mindsetReportProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final username = ref.read(authControllerProvider).user?.email ??
      ref.read(localStorageProvider).username ??
      '';
  if (username.isEmpty) return null;
  final api = ref.read(apiServiceProvider);
  return api.getMindsetReport(username);
});

/// `/career-report` — the 9-section Mindset Analysis Report
/// (ported from the web `CareerReport` page).
class CareerReportPage extends ConsumerWidget {
  const CareerReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mindsetReportProvider);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: async.when(
            loading: () => const _ReportLoading(),
            error: (e, _) => _ReportError(
              message: e is ApiException ? e.message : 'Failed to load report. Please try again.',
              onRetry: () => ref.invalidate(mindsetReportProvider),
            ),
            data: (report) {
              if (report == null) {
                return const _ReportError(
                  message: 'Complete the assessment first to view your mindset report.',
                );
              }
              return _ReportBody(report: report);
            },
          ),
        ),
      ),
    );
  }
}

class _ReportLoading extends StatelessWidget {
  const _ReportLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary600),
          SizedBox(height: AppSpacing.s2),
          Text('Loading your mindset report…', style: TextStyle(color: AppColors.neutral600)),
        ],
      ),
    );
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights_rounded, size: 56, color: AppColors.primary400),
            const SizedBox(height: AppSpacing.s2),
            Text('Report Not Available',
                style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s1),
            Text(message,
                style: const TextStyle(color: AppColors.neutral500), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s3),
            if (onRetry != null)
              OutlinedButton(onPressed: onRetry, child: const Text('Retry'))
            else
              OutlinedButton(
                onPressed: () {
                  final c = GoRouter.of(context);
                  c.canPop() ? c.pop() : c.go(Routes.recommendations);
                },
                child: const Text('Back'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final Map<String, dynamic> report;

  Map<String, dynamic> _sec(String key) =>
      (report[key] as Map?)?.cast<String, dynamic>() ?? const {};

  @override
  Widget build(BuildContext context) {
    final onboarding = _sec('onboarding');
    final motivation = _sec('motivation');
    final cognitive = _sec('cognitiveStyle');
    final academic = _sec('academic');
    final behavioral = _sec('behavioral');
    final constraints = _sec('constraints');
    final calibration = _sec('calibration');
    final aptitude = _sec('aptitude');
    final persistence = _sec('persistence');
    final topCareer = (report['topCareer'] as Map?)?.cast<String, dynamic>();

    final favSubjects = (academic['favoriteSubjects'] as List?)?.cast<String>() ?? const [];
    final subjectMarks = (academic['subjectMarks'] as Map?)?.cast<String, dynamic>() ?? const {};
    final flags = (persistence['counselorFlags'] as List?)?.cast<String>() ?? const [];

    return Column(
      children: [
        _Header(name: onboarding['name'] as String? ?? ''),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s3, AppSpacing.pageH, AppSpacing.s5),
            children: [
              // 1 — Motivation Profile
              _Section(
                icon: Icons.track_changes_rounded,
                iconColor: AppColors.primary600,
                tileColor: AppColors.primary100,
                title: '1. Motivation Profile',
                child: Column(children: [
                  _Row(label: 'Why here', value: ReportLabels.whyHere[motivation['whyHere']]),
                  _Row(label: '5-year vision', value: ReportLabels.vision[motivation['fiveYearVision']]),
                  _Row(label: 'Career thinking about', value: motivation['careerThinking'] as String?),
                  _Row(label: 'Career ruled out', value: motivation['careerRuledOut'] as String?),
                ]),
              ),
              // 2 — Cognitive & Work Style
              _Section(
                icon: Icons.lightbulb_outline_rounded,
                iconColor: AppColors.amber600,
                tileColor: AppColors.amber100,
                title: '2. Cognitive & Work Style',
                child: Column(children: [
                  _Row(label: 'Free Sunday preference', value: ReportLabels.freeSunday[cognitive['freeSunday']]),
                  _Row(label: 'Group project role', value: ReportLabels.groupRole[cognitive['groupRole']]),
                  _Row(label: 'Job deal-breaker', value: ReportLabels.jobBothers[cognitive['jobBothers']]),
                ]),
              ),
              // 3 — Academic Strengths
              _Section(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.emerald600,
                tileColor: AppColors.emerald100,
                title: '3. Academic Strengths vs Aspirations',
                child: Column(children: [
                  _Row(label: 'Favourite subjects', value: favSubjects.join(', ')),
                  _Row(label: 'Most difficult subject', value: academic['difficultSubject'] as String?),
                  _Row(label: 'Study experience', value: ReportLabels.studyExp[academic['studyExperience']]),
                  if (favSubjects.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s2),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Marks in favourite subjects',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.neutral500)),
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final sub in favSubjects)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.emerald100.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.emerald100),
                            ),
                            child: Text('$sub: ${subjectMarks[sub] ?? '—'}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald600)),
                          ),
                      ],
                    ),
                  ],
                ]),
              ),
              // 4 — Behavioral Signals
              _Section(
                icon: Icons.groups_rounded,
                iconColor: AppColors.secondary600,
                tileColor: AppColors.secondary100,
                title: '4. Behavioral Signals',
                child: Column(children: [
                  _Row(
                    label: 'Outside activities',
                    value: ((behavioral['outsideActivities'] as List?)?.cast<String>() ?? const [])
                        .map((a) => a.replaceAll('-', ' '))
                        .join(', '),
                  ),
                  _Row(label: 'External validation', value: ReportLabels.extVal[behavioral['externalValidation']]),
                  _Row(label: 'Self-initiated activity', value: behavioral['selfInitiated'] as String?),
                ]),
              ),
              // 5 — Constraints & Values
              _Section(
                icon: Icons.favorite_outline_rounded,
                iconColor: const Color(0xFFE11D48),
                tileColor: const Color(0xFFFFE4E6),
                title: '5. Constraints & Values',
                child: Column(children: [
                  _Row(
                    label: 'Open to study in',
                    value: ((constraints['studyLocation'] as List?)?.cast<String>() ?? const []).join(', '),
                  ),
                  _Row(label: 'Family budget discussion', value: ReportLabels.budget[constraints['familyBudget']]),
                  _Row(
                    label: 'Top career values',
                    value: ((constraints['careerValues'] as List?)?.cast<String>() ?? const [])
                        .map((v) => ReportLabels.values[v] ?? v)
                        .join(' → '),
                  ),
                ]),
              ),
              // 6 — Persistence Profile
              _Section(
                icon: Icons.shield_outlined,
                iconColor: AppColors.accent600,
                tileColor: AppColors.accent100,
                title: '6. Persistence Profile',
                child: Column(children: [
                  _Row(label: 'Effort rating', value: persistence['effortRating'] as String?, fallback: 'Not completed'),
                  _Row(label: 'Approach style', value: persistence['approachStyle'] as String?, fallback: 'Not completed'),
                  _Row(
                    label: 'Sliding tile — highest tier',
                    value: persistence['highestTier'] != null ? 'Tier ${persistence['highestTier']}' : null,
                    fallback: 'Not completed',
                  ),
                  _Row(
                    label: 'Constraint grid approach',
                    value: (persistence['constraintGridApproach'] as String?)?.replaceAll('-', ' '),
                    fallback: 'Not completed',
                  ),
                  _Row(
                    label: 'Black box approach',
                    value: (persistence['blackBoxApproach'] as String?)?.replaceAll('-', ' '),
                    fallback: 'Not completed',
                  ),
                  _Row(
                    label: 'Abandoned last guess',
                    value: persistence['blackBoxAbandonedLastGuess'] == true
                        ? 'Yes — fear of failure signal'
                        : (persistence.containsKey('blackBoxSolved') ? 'No' : null),
                    fallback: 'Not completed',
                  ),
                  if (flags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s2),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.error_outline_rounded, size: 16, color: AppColors.destructive),
                        SizedBox(width: 4),
                        Text('Counselor Flags',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.destructive)),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    for (final flag in flags)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.destructiveBg,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.destructiveBorder),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.destructive),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(flag, style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C))),
                          ),
                        ]),
                      ),
                  ],
                ]),
              ),
              // 7 — Aptitude Pattern
              _Section(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.primary600,
                tileColor: AppColors.primary100,
                title: '7. Aptitude Pattern',
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.s2,
                  crossAxisSpacing: AppSpacing.s2,
                  childAspectRatio: 1.5,
                  children: [
                    _AptitudeTile(label: 'Quantitative', score: _asInt(aptitude['numberSense'])),
                    _AptitudeTile(label: 'Verbal', score: _asInt(aptitude['wordSense'])),
                    _AptitudeTile(label: 'Spatial', score: _asInt(aptitude['shapeSense'])),
                    _AptitudeTile(label: 'Abstract / Logic', score: _asInt(aptitude['logicSense'])),
                  ],
                ),
              ),
              // 8 — Final Calibration
              _Section(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFEA580C),
                tileColor: const Color(0xFFFFEDD5),
                title: '8. Final Calibration',
                child: Column(children: [
                  _Row(label: 'Planning style', value: ReportLabels.planning[calibration['planningStyle']]),
                  _Row(label: 'Stress response', value: ReportLabels.stress[calibration['stressResponse']]),
                  _Row(label: 'Reaction to surprises', value: ReportLabels.surprise[calibration['surpriseReaction']]),
                ]),
              ),
              // 9 — Top Career Match
              if (topCareer != null) _TopCareerCard(career: topCareer),
            ],
          ),
        ),
      ],
    );
  }

  static int? _asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral700),
            onPressed: () {
              final c = GoRouter.of(context);
              c.canPop() ? c.pop() : c.go(Routes.recommendations);
            },
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryButton,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.psychology_rounded, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.s1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mindset Analysis Report',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                if (name.isNotEmpty)
                  Text(name, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.iconColor,
    required this.tileColor,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Color tileColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
              ),
            ]),
            const SizedBox(height: AppSpacing.s2),
            child,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.fallback = '—'});

  final String label;
  final String? value;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final shown = (value == null || value!.trim().isEmpty) ? fallback : value!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.neutral500)),
          const SizedBox(height: 2),
          Text(shown, style: const TextStyle(fontSize: 14, color: AppColors.neutral800)),
        ],
      ),
    );
  }
}

class _AptitudeTile extends StatelessWidget {
  const _AptitudeTile({required this.label, required this.score});

  final String label;
  final int? score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral500)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: score?.toString() ?? '—',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.neutral900),
              children: const [
                TextSpan(text: '/8', style: TextStyle(fontSize: 13, color: AppColors.neutral400)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ReportLabels.aptitudeBg(score),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(ReportLabels.aptitudeLabel(score),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: ReportLabels.aptitudeFg(score))),
          ),
        ],
      ),
    );
  }
}

class _TopCareerCard extends StatelessWidget {
  const _TopCareerCard({required this.career});

  final Map<String, dynamic> career;

  @override
  Widget build(BuildContext context) {
    final match = career['matchScore'] ?? career['match'];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryButton,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.trending_up_rounded, color: AppColors.white, size: 24),
            const SizedBox(width: AppSpacing.s1),
            Text('Top Career Match',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)),
            const Spacer(),
            if (match != null)
              Text('$match%',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white)),
          ]),
          const SizedBox(height: AppSpacing.s2),
          Text((career['title'] ?? '') as String,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
          const SizedBox(height: AppSpacing.s1),
          Text((career['description'] ?? career['summary'] ?? '') as String,
              style: const TextStyle(color: AppColors.primary100, height: 1.4)),
          const SizedBox(height: AppSpacing.s3),
          ElevatedButton.icon(
            onPressed: () => context.go(Routes.recommendations),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary600,
              elevation: 0,
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('View All Recommendations'),
          ),
        ],
      ),
    );
  }
}
