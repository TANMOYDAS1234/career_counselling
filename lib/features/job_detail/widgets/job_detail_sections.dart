import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/job_detail.dart';

Future<void> _openUrl(String url) async {
  if (url.isEmpty || url == '#') return;
  final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Section heading row used at the top of each section.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.icon, this.title, {super.key});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primary100, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, color: AppColors.primary700, size: 20),
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20))),
          ],
        ),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {this.icon = Icons.check_circle_rounded, this.color = AppColors.primary600});
  final String text;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(height: 1.45, color: AppColors.neutral700))),
          ],
        ),
      );
}

class _LinkButton extends StatelessWidget {
  const _LinkButton(this.label, this.url);
  final String label;
  final String url;
  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || url == '#') return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => _openUrl(url),
      icon: const Icon(Icons.open_in_new_rounded, size: 15),
      label: Text(label),
      style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.primary600),
    );
  }
}

class OverviewSection extends StatelessWidget {
  const OverviewSection(this.o, {super.key});
  final Overview o;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.description_outlined, 'Overview'),
        if (o.description.isNotEmpty)
          AppCard(child: Text(o.description, style: const TextStyle(height: 1.55, color: AppColors.neutral700))),
        if (o.keyResponsibilities.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Responsibilities', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s1),
                for (final r in o.keyResponsibilities) _Bullet(r),
              ],
            ),
          ),
        ],
        if (o.whySuitable.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why This Suits You', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s1),
                for (final w in o.whySuitable) _Bullet(w, icon: Icons.star_rounded, color: AppColors.amber600),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class PathwaySection extends StatelessWidget {
  const PathwaySection(this.p, {super.key});
  final CareerPathway p;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.timeline_rounded, 'Career Pathway'),
        for (var i = 0; i < p.steps.length; i++)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: AppColors.primary600, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${i + 1}',
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(p.steps[i].phase, style: Theme.of(context).textTheme.titleMedium)),
                          if (p.steps[i].duration.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(p.steps[i].duration,
                                  style: const TextStyle(fontSize: 11, color: AppColors.primary700)),
                            ),
                        ],
                      ),
                      if (p.steps[i].description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(p.steps[i].description, style: const TextStyle(color: AppColors.neutral600, height: 1.45)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ).paddedBottom(),
      ],
    );
  }
}

class InstitutesSection extends StatelessWidget {
  const InstitutesSection(this.t, {super.key});
  final TopInstitutes t;
  @override
  Widget build(BuildContext context) {
    final groups = <(String, List<Institute>)>[
      ('Government', t.government),
      ('Private', t.private),
      ('Distance Learning', t.distanceLearning),
      ('Online', t.online),
    ].where((g) => g.$2.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.account_balance_outlined, 'Top Institutes'),
        for (final (label, list) in groups) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.neutral800)),
          ),
          for (final i in list) _InstituteCard(i).paddedBottom(),
        ],
      ],
    );
  }
}

class _InstituteCard extends StatelessWidget {
  const _InstituteCard(this.i);
  final Institute i;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(i.name, style: Theme.of(context).textTheme.titleMedium)),
              const Icon(Icons.star_rounded, size: 16, color: AppColors.amber600),
              const SizedBox(width: 2),
              Text(i.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          if (i.location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.neutral500),
                const SizedBox(width: 4),
                Expanded(child: Text(i.location, style: const TextStyle(fontSize: 13, color: AppColors.neutral600))),
              ]),
            ),
          if (i.department.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(i.department, style: const TextStyle(fontSize: 13, color: AppColors.neutral600)),
            ),
          if (i.eligibility.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('Eligibility: ${i.eligibility}',
                  style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
            ),
          _LinkButton('Visit website', i.website),
        ],
      ),
    );
  }
}

class FeesSection extends StatelessWidget {
  const FeesSection(this.f, {super.key});
  final FeesInvestment f;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.currency_rupee_rounded, 'Fees & Investment'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary50, AppColors.secondary50]),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.primary200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Investment', style: TextStyle(fontSize: 13, color: AppColors.neutral600)),
              const SizedBox(height: 4),
              Text(f.totalRange.isEmpty ? '—' : f.totalRange,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary700)),
              if (f.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(f.description, style: const TextStyle(fontSize: 13, color: AppColors.neutral600)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        for (final b in f.breakdown)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.phase, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (b.details.isNotEmpty)
                        Text(b.details, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                    ],
                  ),
                ),
                Text(b.cost, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary600)),
              ],
            ),
          ).paddedBottom(),
      ],
    );
  }
}

class ScholarshipsSection extends StatelessWidget {
  const ScholarshipsSection(this.s, {super.key});
  final Scholarships s;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.savings_outlined, 'Scholarships & Financial Aid'),
        if (s.governmentPrivate.isNotEmpty) ...[
          _groupLabel('Scholarships'),
          for (final x in s.governmentPrivate)
            _AidCard(title: x.name, value: x.amount, sub: x.eligibility, url: x.website).paddedBottom(),
        ],
        if (s.bankLoans.isNotEmpty) ...[
          _groupLabel('Education Loans'),
          for (final x in s.bankLoans)
            _AidCard(title: x.name, value: x.amount, sub: 'Interest: ${x.interestRate}', url: x.website).paddedBottom(),
        ],
        if (s.governmentSchemes.isNotEmpty) ...[
          _groupLabel('Government Schemes'),
          for (final x in s.governmentSchemes)
            _AidCard(title: x.name, value: x.benefits, sub: x.eligibility, url: x.website).paddedBottom(),
        ],
      ],
    );
  }

  Widget _groupLabel(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.neutral800)),
      );
}

class _AidCard extends StatelessWidget {
  const _AidCard({required this.title, required this.value, required this.sub, required this.url});
  final String title, value, sub, url;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(value, style: const TextStyle(color: AppColors.primary600, fontWeight: FontWeight.w600)),
            ),
          if (sub.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.neutral600)),
            ),
          _LinkButton('Learn more', url),
        ],
      ),
    );
  }
}

class JobMarketSection extends StatelessWidget {
  const JobMarketSection(this.m, {super.key});
  final JobMarket m;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.bar_chart_rounded, 'Job Market'),
        Row(
          children: [
            Expanded(child: _StatCard('Demand', '${m.demandLevel}%', AppColors.primary600)),
            const SizedBox(width: AppSpacing.s2),
            Expanded(child: _StatCard('Success Rate', '${m.successRate}%', AppColors.accent600)),
          ],
        ),
        if (m.hiringTrends.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hiring Trends', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s2),
                SizedBox(height: 180, child: _HiringTrendChart(m.hiringTrends)),
              ],
            ),
          ),
        ],
        if (m.topCompanies.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Hiring Companies', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s1),
                for (final co in m.topCompanies)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(co.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        if (co.packageRange.isNotEmpty)
                          Text(co.packageRange, style: const TextStyle(fontSize: 13, color: AppColors.primary600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (m.keyInsights.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Insights', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s1),
                for (final k in m.keyInsights) _Bullet(k, icon: Icons.insights_rounded),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.s2),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
          ],
        ),
      );
}

class _HiringTrendChart extends StatelessWidget {
  const _HiringTrendChart(this.trends);
  final List<HiringTrend> trends;
  @override
  Widget build(BuildContext context) {
    final spots = [for (var i = 0; i < trends.length; i++) FlSpot(i.toDouble(), trends[i].openings.toDouble())];
    final maxY = trends.map((t) => t.openings).fold<int>(0, (a, b) => b > a ? b : a).toDouble();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 10 : maxY * 1.2,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= trends.length) return const SizedBox.shrink();
                final label = trends[i].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label.length > 3 ? label.substring(0, 3) : label,
                      style: const TextStyle(fontSize: 10, color: AppColors.neutral500)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary600,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.primary100.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

class CertificationsSection extends StatelessWidget {
  const CertificationsSection(this.list, {super.key});
  final List<Certification> list;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.workspace_premium_outlined, 'Certifications'),
        for (final c in list)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: Theme.of(context).textTheme.titleMedium),
                if (c.provider.isNotEmpty)
                  Text(c.provider, style: const TextStyle(fontSize: 13, color: AppColors.neutral600)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (c.duration.isNotEmpty) _Tag(Icons.schedule_rounded, c.duration),
                  if (c.cost.isNotEmpty) _Tag(Icons.currency_rupee_rounded, c.cost),
                  _Tag(Icons.trending_up_rounded, 'Impact: ${c.impact}'),
                ]),
                _LinkButton('View certification', c.link),
              ],
            ),
          ).paddedBottom(),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppColors.neutral600),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.neutral700)),
        ]),
      );
}

class SalarySection extends StatelessWidget {
  const SalarySection(this.s, {super.key});
  final SalaryGrowth s;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.trending_up_rounded, 'Salary Growth'),
        for (final p in s.progression)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.role, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(p.experience, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                    ],
                  ),
                ),
                Text(p.salary, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent600)),
              ],
            ),
          ).paddedBottom(),
        if (s.cityComparison.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s1),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('City Comparison', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s2),
                SizedBox(height: 200, child: _CityChart(s.cityComparison)),
              ],
            ),
          ),
        ],
        if (s.salaryTips.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Salary Tips', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s1),
                for (final t in s.salaryTips) _Bullet(t, icon: Icons.lightbulb_outline_rounded, color: AppColors.amber600),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CityChart extends StatelessWidget {
  const _CityChart(this.cities);
  final List<CityComparison> cities;

  double _numeric(String s) {
    final m = RegExp(r'[\d,]+(?:\.\d+)?').firstMatch(s);
    if (m == null) return 0;
    return double.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final values = cities.map((c) => _numeric(c.salary)).toList();
    final maxV = values.fold<double>(0, (a, b) => b > a ? b : a);
    return BarChart(
      BarChartData(
        maxY: maxV == 0 ? 10 : maxV * 1.2,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= cities.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(cities[i].city,
                      style: const TextStyle(fontSize: 10, color: AppColors.neutral500)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < cities.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i],
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.primary600, AppColors.secondary500],
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

class ExpertsSection extends StatelessWidget {
  const ExpertsSection(this.list, {super.key});
  final List<Expert> list;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.groups_outlined, 'Industry Experts'),
        for (final e in list)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary100,
                      child: Text(
                        e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary700, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.name, style: Theme.of(context).textTheme.titleMedium),
                          Text([e.designation, e.company].where((s) => s.isNotEmpty).join(' · '),
                              style: const TextStyle(fontSize: 13, color: AppColors.neutral600)),
                          if (e.experience.isNotEmpty)
                            Text(e.experience, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (e.advice.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s2),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text('“${e.advice}”',
                        style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.neutral700, height: 1.45)),
                  ),
                ],
              ],
            ),
          ).paddedBottom(),
      ],
    );
  }
}

class SkillsSection extends StatelessWidget {
  const SkillsSection(this.s, {super.key});
  final SkillsLearning s;

  @override
  Widget build(BuildContext context) {
    final groups = <(String, Color, List<SkillItem>)>[
      ('High Priority', AppColors.primary600, s.high),
      ('Medium Priority', AppColors.secondary600, s.medium),
      ('Good to Have', AppColors.accent600, s.low),
    ].where((g) => g.$3.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.school_outlined, 'Skills & Learning'),
        for (final (label, color, list) in groups) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.neutral800)),
              ],
            ),
          ),
          for (final skill in list) _SkillCard(skill, color).paddedBottom(),
        ],
      ],
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard(this.s, this.color);
  final SkillItem s;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.name, style: Theme.of(context).textTheme.titleMedium),
          if (s.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(s.description, style: const TextStyle(fontSize: 13, color: AppColors.neutral600, height: 1.4)),
            ),
          Row(
            children: [
              if (s.courseUrl.isNotEmpty && s.courseUrl != '#') _LinkButton('Course', s.courseUrl),
              if (s.videoUrl.isNotEmpty && s.videoUrl != '#') ...[
                const SizedBox(width: AppSpacing.s2),
                TextButton.icon(
                  onPressed: () => _openUrl(s.videoUrl),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                  label: const Text('Video'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.destructive),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class RoadmapSection extends StatelessWidget {
  const RoadmapSection(this.r, {super.key});
  final Roadmap90Days r;

  static const _phaseColors = [AppColors.primary600, AppColors.secondary600, AppColors.accent600];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Icons.map_outlined, '90-Day Roadmap'),
        if (r.overview.isNotEmpty || r.totalDuration.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s3),
            margin: const EdgeInsets.only(bottom: AppSpacing.s2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary50, AppColors.accent50]),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.primary200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.totalDuration.isNotEmpty)
                  Text(r.totalDuration,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary700)),
                if (r.overview.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(r.overview, style: const TextStyle(fontSize: 13, color: AppColors.neutral600, height: 1.4)),
                ],
              ],
            ),
          ),
        for (var i = 0; i < r.phases.length; i++)
          _PhaseCard(phase: r.phases[i], color: _phaseColors[i % _phaseColors.length], index: i).paddedBottom(),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phase, required this.color, required this.index});
  final RoadmapPhase phase;
  final Color color;
  final int index;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(child: Text(phase.title, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          if (phase.goals.isNotEmpty) _PhaseGroup('Goals', phase.goals, Icons.flag_outlined, color),
          if (phase.tasks.isNotEmpty) _PhaseGroup('Tasks', phase.tasks, Icons.task_alt_rounded, color),
          if (phase.progressIndicators.isNotEmpty)
            _PhaseGroup('Progress markers', phase.progressIndicators, Icons.check_circle_outline_rounded, color),
        ],
      ),
    );
  }
}

class _PhaseGroup extends StatelessWidget {
  const _PhaseGroup(this.label, this.items, this.icon, this.color);
  final String label;
  final List<String> items;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neutral500)),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(height: 1.4, color: AppColors.neutral700))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

extension _PaddedBottom on Widget {
  Widget paddedBottom() => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.s2), child: this);
}
