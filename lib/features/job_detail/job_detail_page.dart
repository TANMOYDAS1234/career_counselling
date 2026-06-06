import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/i18n/language_controller.dart';
import '../../core/i18n/translated_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/edubot_app_bar.dart';
import '../../core/widgets/rotating_status.dart';
import '../auth/auth_controller.dart';
import 'job_detail_controller.dart';
import 'widgets/job_detail_sections.dart';

const _navItems = <(String, IconData)>[
  ('Overview', Icons.description_outlined),
  ('Pathway', Icons.timeline_rounded),
  ('Skills', Icons.school_outlined),
  ('Roadmap', Icons.map_outlined),
  ('Institutes', Icons.account_balance_outlined),
  ('Fees', Icons.currency_rupee_rounded),
  ('Aid', Icons.savings_outlined),
  ('Market', Icons.bar_chart_rounded),
  ('Certs', Icons.workspace_premium_outlined),
  ('Salary', Icons.trending_up_rounded),
  ('Experts', Icons.groups_outlined),
];

class JobDetailPage extends ConsumerStatefulWidget {
  const JobDetailPage({super.key, required this.roleId});
  final String roleId;

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  late final JobDetailController _controller;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    _controller = JobDetailController(
      api: ref.read(apiServiceProvider),
      storage: ref.read(localStorageProvider),
      username: ref.read(authControllerProvider).user?.email,
      roleId: widget.roleId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _downloadingPdf = false;

  Future<void> _downloadPdf() async {
    final s = _controller.state;
    if (_downloadingPdf) return;
    if (!s.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText('Please wait — the report is still being generated.')),
      );
      return;
    }
    setState(() => _downloadingPdf = true);
    // Engaging "thinking" dialog while the PDF renders server-side.
    showDialog(context: context, barrierDismissible: false, builder: (_) => const _PdfDialog());
    final messenger = ScaffoldMessenger.of(context);
    void closeDialog() {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }

    try {
      final api = ref.read(apiServiceProvider);
      final lang = ref.read(languageProvider);
      final bytes = await api.generatePdf(
        roleId: widget.roleId,
        roleTitle: s.roleTitle,
        targetLanguage: lang,
        detailData: s.detail.toJson(),
      );
      final dir = await getApplicationDocumentsDirectory();
      final safe = s.roleTitle.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
      final file = File('${dir.path}/EduBot-Career-Report-$safe.pdf');
      await file.writeAsBytes(bytes, flush: true);
      closeDialog();
      final res = await OpenFilex.open(file.path);
      if (res.type != ResultType.done && mounted) {
        messenger.showSnackBar(SnackBar(content: TranslatedText('Saved to ${file.path}')));
      }
    } on ApiException catch (e) {
      closeDialog();
      messenger.showSnackBar(
        SnackBar(content: TranslatedText(e.message), backgroundColor: AppColors.destructive),
      );
    } catch (_) {
      closeDialog();
      messenger.showSnackBar(
        const SnackBar(content: TranslatedText('Could not generate the PDF.'), backgroundColor: AppColors.destructive),
      );
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EduBotAppBar(),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final s = _controller.state;
            final building = !s.done;
            return Column(
              children: [
                _Header(title: s.roleTitle, onPdf: _downloadPdf, busy: _downloadingPdf),
                if (building && s.loaded == 0)
                  // Nothing ready yet (incl. server cold-start) — reassure + show progress.
                  Expanded(child: _InitialLoader(loaded: s.loaded, total: s.total))
                else ...[
                  if (building) _ProgressBanner(loaded: s.loaded, total: s.total),
                  _SectionNav(selected: _section, onSelect: (i) => setState(() => _section = i)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s1, AppSpacing.pageH, AppSpacing.s5),
                      child: _SectionContent(state: s, section: _section),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onPdf, this.busy = false});
  final String title;
  final VoidCallback onPdf;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.primary),
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s3, AppSpacing.pageH, AppSpacing.s3),
      child: Row(
        children: [
          Expanded(
            child: TranslatedText(title,
                style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          IconButton(
            onPressed: busy ? null : onPdf,
            icon: busy
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white),
                  )
                : const Icon(Icons.download_rounded, color: AppColors.white),
            tooltip: 'Download PDF',
          ),
        ],
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.loaded, required this.total});
  final int loaded, total;
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((loaded / total) * 100).round();
    return Container(
      width: double.infinity,
      color: AppColors.primary50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary600),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: TranslatedText('Adding more details — you can read what’s ready',
                    style: TextStyle(fontSize: 12.5, color: AppColors.primary700, fontWeight: FontWeight.w600)),
              ),
              Text('$loaded/$total · $pct%',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.primary700, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? null : loaded / total,
              minHeight: 5,
              backgroundColor: AppColors.primary100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen reassuring loader shown until the first section is ready
/// (covers server cold-start on free hosting).
class _InitialLoader extends StatelessWidget {
  const _InitialLoader({required this.loaded, required this.total});
  final int loaded, total;
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((loaded / total) * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 34),
            ),
            const SizedBox(height: AppSpacing.s3),
            TranslatedText('Building your career report', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s2),
            const SizedBox(
              height: 44,
              child: RotatingStatus(messages: kReportThinkingMessages),
            ),
            const SizedBox(height: 4),
            const TranslatedText('This can take up to a minute on first load.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neutral500, fontSize: 12.5)),
            const SizedBox(height: AppSpacing.s3),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? null : loaded / total,
                minHeight: 8,
                backgroundColor: AppColors.neutral100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary600),
              ),
            ),
            const SizedBox(height: AppSpacing.s1),
            Text('$loaded of $total sections ready · $pct%',
                style: const TextStyle(color: AppColors.primary700, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _SectionNav extends StatelessWidget {
  const _SectionNav({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: 8),
        itemCount: _navItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, icon) = _navItems[i];
          final sel = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary600 : AppColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: sel ? AppColors.primary600 : AppColors.neutral200),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: sel ? AppColors.white : AppColors.neutral600),
                  const SizedBox(width: 6),
                  TranslatedText(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? AppColors.white : AppColors.neutral700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  const _SectionContent({required this.state, required this.section});
  final JobDetailState state;
  final int section;

  @override
  Widget build(BuildContext context) {
    final d = state.detail;
    // Map nav index → whether that section's data is present.
    final widgets = <Widget>[
      OverviewSection(d.overview),
      PathwaySection(d.careerPathway),
      SkillsSection(d.skillsLearning),
      RoadmapSection(d.roadmap90Days),
      InstitutesSection(d.topInstitutes),
      FeesSection(d.feesInvestment),
      ScholarshipsSection(d.scholarships),
      JobMarketSection(d.jobMarket),
      CertificationsSection(d.certifications),
      SalarySection(d.salaryGrowth),
      ExpertsSection(d.industryExperts),
    ];
    final empty = <bool>[
      d.overview.description.isEmpty && d.overview.keyResponsibilities.isEmpty,
      d.careerPathway.steps.isEmpty,
      d.skillsLearning.isEmpty,
      d.roadmap90Days.isEmpty,
      d.topInstitutes.isEmpty,
      d.feesInvestment.totalRange.isEmpty && d.feesInvestment.breakdown.isEmpty,
      d.scholarships.isEmpty,
      d.jobMarket.isEmpty,
      d.certifications.isEmpty,
      d.salaryGrowth.isEmpty,
      d.industryExperts.isEmpty,
    ];

    if (empty[section]) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s8),
        child: Center(
          child: Column(
            children: [
              if (!state.done) ...[
                const CircularProgressIndicator(color: AppColors.primary600),
                const SizedBox(height: AppSpacing.s2),
                const TranslatedText('Generating this section...', style: TextStyle(color: AppColors.neutral500)),
              ] else
                const TranslatedText('No data available for this section.',
                    style: TextStyle(color: AppColors.neutral500)),
            ],
          ),
        ),
      );
    }
    return widgets[section];
  }
}

/// Modal shown while the PDF renders server-side — rotating "thinking" lines so
/// the wait feels alive instead of a static "Generating PDF".
class _PdfDialog extends StatelessWidget {
  const _PdfDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            TranslatedText('Preparing your PDF', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s1),
            const SizedBox(
              height: 40,
              child: RotatingStatus(messages: kPdfThinkingMessages),
            ),
          ],
        ),
      ),
    );
  }
}
