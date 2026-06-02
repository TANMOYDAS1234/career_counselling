// Normalized job-role detail, mirroring the web `JobDetail` type. Built section
// by section from /api/career-details responses (see JobDetailParser), cached,
// and persisted via /api/save-job-role.

class Overview {
  const Overview({this.description = '', this.keyResponsibilities = const [], this.whySuitable = const []});
  final String description;
  final List<String> keyResponsibilities;
  final List<String> whySuitable;

  factory Overview.fromJson(Map j) => Overview(
        description: (j['description'] ?? '') as String,
        keyResponsibilities: _strList(j['keyResponsibilities']),
        whySuitable: _strList(j['whySuitable']),
      );
  Map<String, dynamic> toJson() =>
      {'description': description, 'keyResponsibilities': keyResponsibilities, 'whySuitable': whySuitable};
}

class PathwayStep {
  const PathwayStep({required this.phase, required this.duration, required this.description});
  final String phase;
  final String duration;
  final String description;
  factory PathwayStep.fromJson(Map j) => PathwayStep(
        phase: (j['phase'] ?? '') as String,
        duration: (j['duration'] ?? '') as String,
        description: (j['description'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'phase': phase, 'duration': duration, 'description': description};
}

class CareerPathway {
  const CareerPathway({this.currentLevel = '', this.steps = const []});
  final String currentLevel;
  final List<PathwayStep> steps;
  factory CareerPathway.fromJson(Map j) => CareerPathway(
        currentLevel: (j['currentLevel'] ?? '') as String,
        steps: _mapList(j['steps'], PathwayStep.fromJson),
      );
  Map<String, dynamic> toJson() =>
      {'currentLevel': currentLevel, 'steps': steps.map((e) => e.toJson()).toList()};
}

class Institute {
  const Institute({
    required this.name,
    required this.location,
    required this.department,
    required this.rating,
    required this.website,
    required this.eligibility,
  });
  final String name;
  final String location;
  final String department;
  final double rating;
  final String website;
  final String eligibility;
  factory Institute.fromJson(Map j) => Institute(
        name: (j['name'] ?? '') as String,
        location: (j['location'] ?? '') as String,
        department: (j['department'] ?? '') as String,
        rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : double.tryParse('${j['rating']}') ?? 4.0,
        website: (j['website'] ?? '') as String,
        eligibility: (j['eligibility'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {
        'name': name, 'location': location, 'department': department,
        'rating': rating, 'website': website, 'eligibility': eligibility,
      };
}

class TopInstitutes {
  const TopInstitutes({
    this.government = const [],
    this.private = const [],
    this.distanceLearning = const [],
    this.online = const [],
  });
  final List<Institute> government;
  final List<Institute> private;
  final List<Institute> distanceLearning;
  final List<Institute> online;
  factory TopInstitutes.fromJson(Map j) => TopInstitutes(
        government: _mapList(j['government'], Institute.fromJson),
        private: _mapList(j['private'], Institute.fromJson),
        distanceLearning: _mapList(j['distanceLearning'], Institute.fromJson),
        online: _mapList(j['online'], Institute.fromJson),
      );
  Map<String, dynamic> toJson() => {
        'government': government.map((e) => e.toJson()).toList(),
        'private': private.map((e) => e.toJson()).toList(),
        'distanceLearning': distanceLearning.map((e) => e.toJson()).toList(),
        'online': online.map((e) => e.toJson()).toList(),
      };
  bool get isEmpty => government.isEmpty && private.isEmpty && distanceLearning.isEmpty && online.isEmpty;
}

class FeeBreakdown {
  const FeeBreakdown({required this.phase, required this.cost, required this.details});
  final String phase;
  final String cost;
  final String details;
  factory FeeBreakdown.fromJson(Map j) => FeeBreakdown(
        phase: (j['phase'] ?? '') as String,
        cost: (j['cost'] ?? '') as String,
        details: (j['details'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'phase': phase, 'cost': cost, 'details': details};
}

class FeesInvestment {
  const FeesInvestment({this.totalRange = '', this.description = '', this.breakdown = const []});
  final String totalRange;
  final String description;
  final List<FeeBreakdown> breakdown;
  factory FeesInvestment.fromJson(Map j) => FeesInvestment(
        totalRange: (j['totalRange'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        breakdown: _mapList(j['breakdown'], FeeBreakdown.fromJson),
      );
  Map<String, dynamic> toJson() =>
      {'totalRange': totalRange, 'description': description, 'breakdown': breakdown.map((e) => e.toJson()).toList()};
}

class Scholarship {
  const Scholarship({required this.name, required this.amount, required this.eligibility, required this.website});
  final String name, amount, eligibility, website;
  factory Scholarship.fromJson(Map j) => Scholarship(
        name: (j['name'] ?? '') as String,
        amount: (j['amount'] ?? '') as String,
        eligibility: (j['eligibility'] ?? '') as String,
        website: (j['website'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'eligibility': eligibility, 'website': website};
}

class BankLoan {
  const BankLoan({required this.name, required this.amount, required this.interestRate, required this.website});
  final String name, amount, interestRate, website;
  factory BankLoan.fromJson(Map j) => BankLoan(
        name: (j['name'] ?? '') as String,
        amount: (j['amount'] ?? '') as String,
        interestRate: (j['interestRate'] ?? '') as String,
        website: (j['website'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'interestRate': interestRate, 'website': website};
}

class GovScheme {
  const GovScheme({required this.name, required this.benefits, required this.eligibility, required this.website});
  final String name, benefits, eligibility, website;
  factory GovScheme.fromJson(Map j) => GovScheme(
        name: (j['name'] ?? '') as String,
        benefits: (j['benefits'] ?? '') as String,
        eligibility: (j['eligibility'] ?? '') as String,
        website: (j['website'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'name': name, 'benefits': benefits, 'eligibility': eligibility, 'website': website};
}

class Scholarships {
  const Scholarships({this.governmentPrivate = const [], this.bankLoans = const [], this.governmentSchemes = const []});
  final List<Scholarship> governmentPrivate;
  final List<BankLoan> bankLoans;
  final List<GovScheme> governmentSchemes;
  factory Scholarships.fromJson(Map j) => Scholarships(
        governmentPrivate: _mapList(j['governmentPrivate'], Scholarship.fromJson),
        bankLoans: _mapList(j['bankLoans'], BankLoan.fromJson),
        governmentSchemes: _mapList(j['governmentSchemes'], GovScheme.fromJson),
      );
  Map<String, dynamic> toJson() => {
        'governmentPrivate': governmentPrivate.map((e) => e.toJson()).toList(),
        'bankLoans': bankLoans.map((e) => e.toJson()).toList(),
        'governmentSchemes': governmentSchemes.map((e) => e.toJson()).toList(),
      };
  bool get isEmpty => governmentPrivate.isEmpty && bankLoans.isEmpty && governmentSchemes.isEmpty;
}

class HiringTrend {
  const HiringTrend({required this.month, required this.openings});
  final String month;
  final int openings;
  factory HiringTrend.fromJson(Map j) => HiringTrend(
        month: (j['month'] ?? '') as String,
        openings: (j['openings'] is num) ? (j['openings'] as num).toInt() : int.tryParse('${j['openings']}') ?? 0,
      );
  Map<String, dynamic> toJson() => {'month': month, 'openings': openings};
}

class TopCompany {
  const TopCompany({required this.name, required this.packageRange, required this.locations});
  final String name;
  final String packageRange;
  final List<String> locations;
  factory TopCompany.fromJson(Map j) => TopCompany(
        name: (j['name'] ?? '') as String,
        packageRange: (j['packageRange'] ?? '') as String,
        locations: _strList(j['locations']),
      );
  Map<String, dynamic> toJson() => {'name': name, 'packageRange': packageRange, 'locations': locations};
}

class JobMarket {
  const JobMarket({
    this.demandLevel = 0,
    this.successRate = 0,
    this.hiringTrends = const [],
    this.topCompanies = const [],
    this.keyInsights = const [],
  });
  final int demandLevel;
  final int successRate;
  final List<HiringTrend> hiringTrends;
  final List<TopCompany> topCompanies;
  final List<String> keyInsights;
  factory JobMarket.fromJson(Map j) => JobMarket(
        demandLevel: (j['demandLevel'] is num) ? (j['demandLevel'] as num).toInt() : 0,
        successRate: (j['successRate'] is num) ? (j['successRate'] as num).toInt() : 0,
        hiringTrends: _mapList(j['hiringTrends'], HiringTrend.fromJson),
        topCompanies: _mapList(j['topCompanies'], TopCompany.fromJson),
        keyInsights: _strList(j['keyInsights']),
      );
  Map<String, dynamic> toJson() => {
        'demandLevel': demandLevel,
        'successRate': successRate,
        'hiringTrends': hiringTrends.map((e) => e.toJson()).toList(),
        'topCompanies': topCompanies.map((e) => e.toJson()).toList(),
        'keyInsights': keyInsights,
      };
  bool get isEmpty => hiringTrends.isEmpty && topCompanies.isEmpty && keyInsights.isEmpty && demandLevel == 0;
}

class Certification {
  const Certification({
    required this.name,
    required this.platform,
    required this.provider,
    required this.duration,
    required this.cost,
    required this.impact,
    required this.link,
  });
  final String name, platform, provider, duration, cost, impact, link;
  factory Certification.fromJson(Map j) => Certification(
        name: (j['name'] ?? '') as String,
        platform: (j['platform'] ?? '') as String,
        provider: (j['provider'] ?? '') as String,
        duration: (j['duration'] ?? '') as String,
        cost: (j['cost'] ?? '') as String,
        impact: (j['impact'] ?? '') as String,
        link: (j['link'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {
        'name': name, 'platform': platform, 'provider': provider,
        'duration': duration, 'cost': cost, 'impact': impact, 'link': link,
      };
}

class SalaryProgression {
  const SalaryProgression({required this.experience, required this.role, required this.salary});
  final String experience, role, salary;
  factory SalaryProgression.fromJson(Map j) => SalaryProgression(
        experience: (j['experience'] ?? '') as String,
        role: (j['role'] ?? '') as String,
        salary: (j['salary'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'experience': experience, 'role': role, 'salary': salary};
}

class CityComparison {
  const CityComparison({required this.city, required this.salary});
  final String city, salary;
  factory CityComparison.fromJson(Map j) => CityComparison(
        city: (j['city'] ?? '') as String,
        salary: (j['salary'] ?? '') as String,
      );
  Map<String, dynamic> toJson() => {'city': city, 'salary': salary};
}

class SalaryGrowth {
  const SalaryGrowth({this.progression = const [], this.cityComparison = const [], this.salaryTips = const []});
  final List<SalaryProgression> progression;
  final List<CityComparison> cityComparison;
  final List<String> salaryTips;
  factory SalaryGrowth.fromJson(Map j) => SalaryGrowth(
        progression: _mapList(j['progression'], SalaryProgression.fromJson),
        cityComparison: _mapList(j['cityComparison'], CityComparison.fromJson),
        salaryTips: _strList(j['salaryTips']),
      );
  Map<String, dynamic> toJson() => {
        'progression': progression.map((e) => e.toJson()).toList(),
        'cityComparison': cityComparison.map((e) => e.toJson()).toList(),
        'salaryTips': salaryTips,
      };
  bool get isEmpty => progression.isEmpty && cityComparison.isEmpty && salaryTips.isEmpty;
}

class Expert {
  const Expert({
    required this.name,
    required this.designation,
    required this.company,
    required this.experience,
    required this.advice,
  });
  final String name, designation, company, experience, advice;
  factory Expert.fromJson(Map j) => Expert(
        name: (j['name'] ?? '') as String,
        designation: (j['designation'] ?? '') as String,
        company: (j['company'] ?? '') as String,
        experience: (j['experience'] ?? '') as String,
        advice: (j['advice'] ?? '') as String,
      );
  Map<String, dynamic> toJson() =>
      {'name': name, 'designation': designation, 'company': company, 'experience': experience, 'advice': advice};
}

class JobDetail {
  const JobDetail({
    required this.roleId,
    this.overview = const Overview(),
    this.careerPathway = const CareerPathway(),
    this.topInstitutes = const TopInstitutes(),
    this.feesInvestment = const FeesInvestment(),
    this.scholarships = const Scholarships(),
    this.jobMarket = const JobMarket(),
    this.certifications = const [],
    this.salaryGrowth = const SalaryGrowth(),
    this.industryExperts = const [],
  });

  final String roleId;
  final Overview overview;
  final CareerPathway careerPathway;
  final TopInstitutes topInstitutes;
  final FeesInvestment feesInvestment;
  final Scholarships scholarships;
  final JobMarket jobMarket;
  final List<Certification> certifications;
  final SalaryGrowth salaryGrowth;
  final List<Expert> industryExperts;

  factory JobDetail.empty(String roleId, String currentLevel) =>
      JobDetail(roleId: roleId, careerPathway: CareerPathway(currentLevel: currentLevel));

  /// Parses the server's normalized `detail` payload (load-job-role).
  factory JobDetail.fromServerJson(String roleId, Map j) => JobDetail(
        roleId: roleId,
        overview: j['overview'] is Map ? Overview.fromJson(j['overview'] as Map) : const Overview(),
        careerPathway: j['careerPathway'] is Map ? CareerPathway.fromJson(j['careerPathway'] as Map) : const CareerPathway(),
        topInstitutes: j['topInstitutes'] is Map ? TopInstitutes.fromJson(j['topInstitutes'] as Map) : const TopInstitutes(),
        feesInvestment: j['feesInvestment'] is Map ? FeesInvestment.fromJson(j['feesInvestment'] as Map) : const FeesInvestment(),
        scholarships: j['scholarships'] is Map ? Scholarships.fromJson(j['scholarships'] as Map) : const Scholarships(),
        jobMarket: j['jobMarket'] is Map ? JobMarket.fromJson(j['jobMarket'] as Map) : const JobMarket(),
        certifications: _mapList(j['certifications'], Certification.fromJson),
        salaryGrowth: j['salaryGrowth'] is Map ? SalaryGrowth.fromJson(j['salaryGrowth'] as Map) : const SalaryGrowth(),
        industryExperts: _mapList(j['industryExperts'], Expert.fromJson),
      );

  Map<String, dynamic> toJson() => {
        'overview': overview.toJson(),
        'careerPathway': careerPathway.toJson(),
        'topInstitutes': topInstitutes.toJson(),
        'feesInvestment': feesInvestment.toJson(),
        'scholarships': scholarships.toJson(),
        'jobMarket': jobMarket.toJson(),
        'certifications': certifications.map((e) => e.toJson()).toList(),
        'salaryGrowth': salaryGrowth.toJson(),
        'industryExperts': industryExperts.map((e) => e.toJson()).toList(),
      };

  JobDetail copyWith({
    Overview? overview,
    CareerPathway? careerPathway,
    TopInstitutes? topInstitutes,
    FeesInvestment? feesInvestment,
    Scholarships? scholarships,
    JobMarket? jobMarket,
    List<Certification>? certifications,
    SalaryGrowth? salaryGrowth,
    List<Expert>? industryExperts,
  }) =>
      JobDetail(
        roleId: roleId,
        overview: overview ?? this.overview,
        careerPathway: careerPathway ?? this.careerPathway,
        topInstitutes: topInstitutes ?? this.topInstitutes,
        feesInvestment: feesInvestment ?? this.feesInvestment,
        scholarships: scholarships ?? this.scholarships,
        jobMarket: jobMarket ?? this.jobMarket,
        certifications: certifications ?? this.certifications,
        salaryGrowth: salaryGrowth ?? this.salaryGrowth,
        industryExperts: industryExperts ?? this.industryExperts,
      );
}

// ── helpers ─────────────────────────────────────────────────────────────────
List<String> _strList(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  if (v is String && v.isNotEmpty) return [v];
  return const [];
}

List<T> _mapList<T>(dynamic v, T Function(Map) fromJson) {
  if (v is List) {
    return v.whereType<Map>().map((e) => fromJson(e)).toList();
  }
  return const [];
}
