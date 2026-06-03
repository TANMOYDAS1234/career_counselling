import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/i18n/language_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/edubot_app_bar.dart';
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
        const SnackBar(content: Text('Please wait — the report is still being generated.')),
      );
      return;
    }
    setState(() => _downloadingPdf = true);
    final messenger = ScaffoldMessenger.of(context)
      ..showSnackBar(const SnackBar(
        content: Text('Generating PDF…'),
        duration: Duration(minutes: 1),
      ));
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
      messenger.hideCurrentSnackBar();
      final res = await OpenFilex.open(file.path);
      if (res.type != ResultType.done && mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
      }
    } on ApiException catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.destructive),
      );
    } catch (_) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not generate the PDF.'), backgroundColor: AppColors.destructive),
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
            return Column(
              children: [
                _Header(title: s.roleTitle, onPdf: _downloadPdf, busy: _downloadingPdf),
                if (!s.done) _ProgressBanner(loaded: s.loaded, total: s.total),
                _SectionNav(selected: _section, onSelect: (i) => setState(() => _section = i)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s1, AppSpacing.pageH, AppSpacing.s5),
                    child: _SectionContent(state: s, section: _section),
                  ),
                ),
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
            child: Text(title,
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
    return Container(
      width: double.infinity,
      color: AppColors.primary50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary600),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Generating your report... ($loaded/$total sections)',
                style: const TextStyle(fontSize: 13, color: AppColors.primary700, fontWeight: FontWeight.w600)),
          ),
        ],
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
                  Text(label,
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
                const Text('Generating this section...', style: TextStyle(color: AppColors.neutral500)),
              ] else
                const Text('No data available for this section.',
                    style: TextStyle(color: AppColors.neutral500)),
            ],
          ),
        ),
      );
    }
    return widgets[section];
  }
}
