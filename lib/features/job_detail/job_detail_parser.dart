import 'package:intl/intl.dart';

import '../../models/job_detail.dart';

/// Merges one AI section's `content` payload into a [JobDetail].
/// Field mappings mirror the web `sectionMap` exactly, including USD→INR.
class JobDetailParser {
  static final _inr = NumberFormat('#,##,##0', 'en_IN');

  /// The sections the backend generates (skills/roadmap are disabled upstream).
  static const sections = [
    'overview', 'pathway', 'institute', 'fees',
    'scholarships', 'jobmarket', 'certifications', 'salary', 'experts',
  ];

  /// Normalized JobDetail keys as returned by /api/load-job-role.
  static const sectionsServerKeys = [
    'overview', 'careerPathway', 'topInstitutes', 'feesInvestment',
    'scholarships', 'jobMarket', 'certifications', 'salaryGrowth', 'industryExperts',
  ];

  static String usdToInr(String s) {
    String repl(Match m) {
      final n = double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
      return '₹${_inr.format((n * 83).round())}';
    }

    return s
        .replaceAllMapped(RegExp(r'\$\s?([\d,]+(?:\.\d+)?)'), repl)
        .replaceAllMapped(RegExp(r'([\d,]+(?:\.\d+)?)\s*USD', caseSensitive: false), repl)
        .replaceAllMapped(RegExp(r'USD\s*([\d,]+(?:\.\d+)?)', caseSensitive: false), repl);
  }

  static JobDetail merge(JobDetail d, String section, Map c) {
    switch (section) {
      case 'overview':
        return _overview(d, c);
      case 'pathway':
        return _pathway(d, c);
      case 'institute':
        return _institute(d, c);
      case 'fees':
        return _fees(d, c);
      case 'scholarships':
        return _scholarships(d, c);
      case 'jobmarket':
        return _jobmarket(d, c);
      case 'certifications':
        return _certifications(d, c);
      case 'salary':
        return _salary(d, c);
      case 'experts':
        return _experts(d, c);
      default:
        return d;
    }
  }

  static List<String> _strList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.isNotEmpty) return [v];
    return const [];
  }

  static JobDetail _overview(JobDetail d, Map c) {
    final o = c['overview'] as Map? ?? const {};
    return d.copyWith(
      overview: Overview(
        description: (o['role_description'] ?? d.overview.description) as String,
        keyResponsibilities: _strList(o['key_responsibilities']).isEmpty
            ? d.overview.keyResponsibilities
            : _strList(o['key_responsibilities']),
        whySuitable: _strList(o['why_suitable']).isEmpty ? d.overview.whySuitable : _strList(o['why_suitable']),
      ),
    );
  }

  static JobDetail _pathway(JobDetail d, Map c) {
    List raw = const [];
    if (c['careerPathway'] is Map && (c['careerPathway'] as Map)['pathway'] is List) {
      raw = (c['careerPathway'] as Map)['pathway'] as List;
    } else if (c['pathway'] is List) {
      raw = c['pathway'] as List;
    } else if (c['steps'] is List) {
      raw = c['steps'] as List;
    } else if (c['careerPathway'] is List) {
      raw = c['careerPathway'] as List;
    }
    final steps = raw.whereType<Map>().map((s) {
      return PathwayStep(
        phase: (s['phase'] ?? s['level'] ?? s['title'] ?? s['step'] ?? s['name'] ?? '') as String,
        duration: (s['duration'] ?? s['time'] ?? s['period'] ?? '') as String,
        description: (s['description'] ?? s['details'] ?? s['content'] ?? '') as String,
      );
    }).where((s) => s.phase.trim().isNotEmpty).toList();
    if (steps.isEmpty) return d;
    return d.copyWith(careerPathway: CareerPathway(currentLevel: d.careerPathway.currentLevel, steps: steps));
  }

  static Institute _inst(Map i, {String fallbackEligibility = 'Not specified'}) => Institute(
        name: (i['name'] ?? '') as String,
        location: (i['location'] ?? '') as String,
        department: (i['department'] ?? i['specialization'] ?? '') as String,
        rating: double.tryParse('${i['rating']}') ?? 4.0,
        website: (i['website'] ?? '') as String,
        eligibility: (i['eligibility'] ?? fallbackEligibility) as String,
      );

  static JobDetail _institute(JobDetail d, Map c) {
    final inst = c['institutes'] as Map? ?? const {};
    List<Institute> map(dynamic v, {String fb = 'Not specified'}) =>
        (v is List ? v : const []).whereType<Map>().map((e) => _inst(e, fallbackEligibility: fb)).toList();
    return d.copyWith(
      topInstitutes: TopInstitutes(
        government: map(inst['government']),
        private: map(inst['private']),
        distanceLearning: map(inst['distance']),
        online: map(inst['online'], fb: 'Open enrollment'),
      ),
    );
  }

  static JobDetail _fees(JobDetail d, Map c) {
    final fees = c['fees'] as Map? ?? const {};
    final rawTotal = (fees['total_investment'] ?? d.feesInvestment.totalRange) as String;
    final converted = usdToInr(rawTotal);
    final m = RegExp(
      r'(?:Rs\.?\s*|₹\s*)?[\d,]+(?:\.\d+)?(?:\s*[-–]\s*(?:Rs\.?\s*|₹\s*)?[\d,]+(?:\.\d+)?)?(?:\s*(?:Crores?|Lakhs?|LPA|Cr\.?|L|K))?',
      caseSensitive: false,
    ).firstMatch(converted);
    final totalRange = (m?.group(0)?.trim().isNotEmpty ?? false) ? m!.group(0)!.trim() : converted.split('(').first.trim();
    final breakdown = (fees['breakdown'] is List ? fees['breakdown'] as List : const [])
        .whereType<Map>()
        .map((b) => FeeBreakdown(
              phase: (b['category'] ?? b['phase'] ?? '') as String,
              cost: (b['range'] ?? b['cost'] ?? '') as String,
              details: (b['duration'] ?? b['details'] ?? '') as String,
            ))
        .toList();
    return d.copyWith(
      feesInvestment: FeesInvestment(
        totalRange: totalRange,
        description: (fees['note'] ?? d.feesInvestment.description) as String,
        breakdown: breakdown,
      ),
    );
  }

  static JobDetail _scholarships(JobDetail d, Map c) {
    final fs = c['financial_support'] as Map? ?? const {};
    List<T> map<T>(dynamic v, T Function(Map) f) =>
        (v is List ? v : const []).whereType<Map>().map(f).toList();
    return d.copyWith(
      scholarships: Scholarships(
        governmentPrivate: map(fs['scholarships'], (s) => Scholarship(
              name: (s['name'] ?? 'Scholarship') as String,
              amount: (s['amount'] ?? 'Amount not specified') as String,
              eligibility: (s['eligibility'] ?? 'Eligibility criteria apply') as String,
              website: (s['link'] ?? '#') as String,
            )),
        bankLoans: map(fs['loans'], (l) => BankLoan(
              name: (l['provider'] ?? 'Education Loan Provider') as String,
              amount: (l['max_amount'] ?? 'Amount varies') as String,
              interestRate: (l['interest_rate'] ?? 'Competitive rates') as String,
              website: (l['link'] ?? '#') as String,
            )),
        governmentSchemes: map(fs['government_schemes'], (g) => GovScheme(
              name: (g['name'] ?? 'Government Scheme') as String,
              benefits: (g['benefit'] ?? 'Financial assistance') as String,
              eligibility: (g['eligibility'] ?? 'Eligibility criteria apply') as String,
              website: (g['link'] ?? '#') as String,
            )),
      ),
    );
  }

  static JobDetail _jobmarket(JobDetail d, Map c) {
    final jm = (c['jobmarket'] ?? c['job_market'] ?? c) as Map;
    final rawInsights = jm['key_insights'] ?? jm['insights'] ?? jm['market_insights'] ?? jm['keyInsights'] ?? [];
    final insights = rawInsights is List
        ? rawInsights
            .map((x) => x is String ? x : (x is Map ? (x['insight'] ?? x['text'] ?? x['point'] ?? '').toString() : x.toString()))
            .where((s) => s.isNotEmpty)
            .toList()
            .cast<String>()
        : (rawInsights is String ? [rawInsights] : <String>[]);
    final trends = (jm['hiring_trends'] is List ? jm['hiring_trends'] as List : const [])
        .whereType<Map>()
        .map((t) => HiringTrend.fromJson(t))
        .toList();
    final companies = (jm['top_companies'] is List ? jm['top_companies'] as List : const [])
        .whereType<Map>()
        .map((co) => TopCompany(
              name: (co['name'] ?? '') as String,
              packageRange: usdToInr((co['package_range'] ?? co['packageRange'] ?? '') as String),
              locations: [(co['type'] ?? '') as String, (co['hiring_frequency'] ?? '') as String]
                  .where((s) => s.isNotEmpty)
                  .toList(),
            ))
        .toList();
    return d.copyWith(
      jobMarket: JobMarket(
        demandLevel: (jm['demand_percentage'] ?? jm['demand_level'] ?? d.jobMarket.demandLevel) is num
            ? ((jm['demand_percentage'] ?? jm['demand_level'] ?? d.jobMarket.demandLevel) as num).toInt()
            : d.jobMarket.demandLevel,
        successRate: int.tryParse('${jm['success_rate']}') ?? d.jobMarket.successRate,
        hiringTrends: trends.isNotEmpty ? trends : d.jobMarket.hiringTrends,
        topCompanies: companies,
        keyInsights: insights,
      ),
    );
  }

  static JobDetail _certifications(JobDetail d, Map c) {
    final list = c['certifications'] is List ? c['certifications'] as List : const [];
    return d.copyWith(
      certifications: list.whereType<Map>().map((cert) {
        final rawCost = '${cert['cost'] ?? ''}';
        final cost = usdToInr(rawCost);
        return Certification(
          name: (cert['name'] ?? '') as String,
          platform: (cert['provider'] ?? '') as String,
          provider: (cert['provider'] ?? '') as String,
          duration: (cert['duration'] ?? '') as String,
          cost: cost.isNotEmpty ? cost : rawCost,
          impact: (cert['career_impact'] ?? 'High') as String,
          link: (cert['link'] ?? '#') as String,
        );
      }).toList(),
    );
  }

  static JobDetail _salary(JobDetail d, Map c) {
    final salary = c['salary'] as Map? ?? const {};
    Map levelCities(String key) => (salary[key] is Map ? (salary[key] as Map)['cities'] : null) as Map? ?? const {};
    final allCities = {...levelCities('fresher_level'), ...levelCities('5years_level')};
    final cityComparison = allCities.entries
        .where((e) => e.key.toString().isNotEmpty && !e.key.toString().startsWith('['))
        .map((e) => CityComparison(
              city: e.key.toString()[0].toUpperCase() + e.key.toString().substring(1),
              salary: e.value.toString(),
            ))
        .toList();
    String? range(String key) => (salary[key] is Map ? (salary[key] as Map)['range'] : null) as String?;
    final progression = <SalaryProgression>[
      if (range('fresher_level') != null)
        SalaryProgression(experience: '0-1 years', role: 'Fresher', salary: range('fresher_level')!),
      if (range('5years_level') != null)
        SalaryProgression(experience: '5 years', role: 'Mid-Level', salary: range('5years_level')!),
      if (range('10years_level') != null)
        SalaryProgression(experience: '10 years', role: 'Senior', salary: range('10years_level')!),
      if (range('15years_level') != null)
        SalaryProgression(experience: '15 years', role: 'Expert', salary: range('15years_level')!),
    ];
    return d.copyWith(
      salaryGrowth: SalaryGrowth(
        progression: progression.isNotEmpty ? progression : d.salaryGrowth.progression,
        cityComparison: cityComparison.isNotEmpty ? cityComparison : d.salaryGrowth.cityComparison,
        salaryTips: _strList(salary['growth_tips']).isEmpty ? d.salaryGrowth.salaryTips : _strList(salary['growth_tips']),
      ),
    );
  }

  static JobDetail _experts(JobDetail d, Map c) {
    final list = c['experts'] is List ? c['experts'] as List : const [];
    if (list.isEmpty) return d;
    return d.copyWith(
      industryExperts: list.whereType<Map>().map((e) {
        final advice = [
          e['key_advice'],
          if (e['achievements'] != null) 'Achievements: ${e['achievements']}',
        ].where((x) => x != null && '$x'.isNotEmpty).join(' | ');
        return Expert(
          name: (e['name'] ?? 'Industry Expert') as String,
          designation: (e['designation'] ?? '') as String,
          company: (e['company'] ?? '') as String,
          experience: (e['experience'] ?? '10+ years') as String,
          advice: advice,
        );
      }).toList(),
    );
  }
}
