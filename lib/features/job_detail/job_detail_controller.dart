import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/network/api_service.dart';
import '../../core/storage/local_storage.dart';
import '../../models/job_detail.dart';
import 'job_detail_parser.dart';

/// Progressive loading state for one role's detail page.
class JobDetailState {
  const JobDetailState({
    required this.detail,
    required this.roleTitle,
    this.loaded = 0,
    this.total = 11,
    this.done = false,
    this.fromCache = false,
    this.error,
  });

  final JobDetail detail;
  final String roleTitle;
  final int loaded;
  final int total;
  final bool done;
  final bool fromCache;
  final String? error;

  double get progress => total == 0 ? 0 : loaded / total;

  JobDetailState copyWith({
    JobDetail? detail,
    String? roleTitle,
    int? loaded,
    bool? done,
    bool? fromCache,
    String? error,
    bool clearError = false,
  }) =>
      JobDetailState(
        detail: detail ?? this.detail,
        roleTitle: roleTitle ?? this.roleTitle,
        loaded: loaded ?? this.loaded,
        total: total,
        done: done ?? this.done,
        fromCache: fromCache ?? this.fromCache,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Screen-scoped controller (owned by the JobDetailPage state). Resolves the
/// role title, then loads detail from cache → server → AI generation.
class JobDetailController extends ChangeNotifier {
  JobDetailController({
    required this.api,
    required this.storage,
    required this.username,
    required this.roleId,
  }) {
    _state = JobDetailState(
      detail: JobDetail.empty(roleId, 'Current Level'),
      roleTitle: _resolveTitle(roleId),
    );
    _load();
  }

  final ApiService api;
  final LocalStorage storage;
  final String? username;
  final String roleId;

  late JobDetailState _state;
  JobDetailState get state => _state;
  int _loaded = 0;

  void _set(JobDetailState s) {
    _state = s;
    notifyListeners();
  }

  String _resolveTitle(String roleId) {
    final index = int.tryParse(roleId.replaceFirst('job-', ''));
    final raw = storage.getRecommendationsRaw();
    if (index != null && raw != null) {
      try {
        final decoded = jsonDecode(raw);
        final careers = (decoded is Map ? decoded['careers'] : decoded) as List?;
        if (careers != null && index < careers.length) {
          return (careers[index] as Map)['title'] as String? ?? 'Career';
        }
      } catch (_) {/* fall through */}
    }
    final last = storage.getLastRoleRaw();
    if (last != null) {
      try {
        final m = jsonDecode(last) as Map;
        if (m['roleId'] == roleId) return m['roleTitle'] as String? ?? 'Career';
      } catch (_) {}
    }
    return 'Career';
  }

  Future<void> _load() async {
    await storage.setLastRoleRaw(jsonEncode({'roleId': roleId, 'roleTitle': _state.roleTitle}));

    // 1) Local cache.
    final cached = storage.getJobDetailRaw(roleId);
    if (cached != null) {
      try {
        final detail = JobDetail.fromServerJson(roleId, jsonDecode(cached) as Map);
        _set(_state.copyWith(detail: detail, loaded: _state.total, done: true, fromCache: true));
        return;
      } catch (_) {/* fall through */}
    }

    // 2) Server-persisted detail (>= 8 of 9 sections present).
    if (username != null && username!.isNotEmpty) {
      try {
        final server = await api.loadJobRole(username!, roleId);
        if (server != null) {
          final present = JobDetailParser.sectionsServerKeys.where((k) => server[k] != null).length;
          if (present >= 10) {
            final detail = JobDetail.fromServerJson(roleId, server);
            await storage.setJobDetailRaw(roleId, jsonEncode(detail.toJson()));
            _set(_state.copyWith(detail: detail, loaded: _state.total, done: true, fromCache: true));
            return;
          }
        }
      } catch (_) {/* fall through */}
    }

    await _generate();
  }

  Future<void> _generate() async {
    final qualifiedTitle = _domainQualify(_state.roleTitle);
    final profile = _buildProfile(_state.roleTitle);
    _loaded = 0;

    // Generate sections in parallel with a bounded worker pool. Overview is
    // first in the queue, so it lands quickly and the (default) Overview tab
    // fills in while the remaining sections stream in.
    final queue = List<String>.from(JobDetailParser.sections);
    const concurrency = 6;
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        await _fetchAndMerge(queue.removeAt(0), qualifiedTitle, profile);
      }
    }

    await Future.wait(List.generate(concurrency, (_) => worker()));

    _set(_state.copyWith(done: true));

    await storage.setJobDetailRaw(roleId, jsonEncode(_state.detail.toJson()));
    if (username != null && username!.isNotEmpty) {
      try {
        await api.saveJobRole(
          username: username!,
          roleId: roleId,
          roleTitle: _state.roleTitle,
          detailData: _state.detail.toJson(),
        );
      } catch (_) {/* non-critical */}
    }
  }

  /// Fetches one section (up to 2 attempts) and merges it. The read-merge-set
  /// after the `await` runs synchronously, so concurrent workers never clobber
  /// each other's sections (each maps to a distinct JobDetail field).
  Future<void> _fetchAndMerge(String section, String title, Map<String, dynamic> profile) async {
    Map? content;
    for (var attempt = 0; attempt < 2 && content == null; attempt++) {
      try {
        content = await api.careerDetails(careerTitle: title, sectionType: section, profile: profile);
      } catch (_) {
        content = null;
      }
    }
    if (content != null) {
      _set(_state.copyWith(detail: JobDetailParser.merge(_state.detail, section, content)));
    }
    _loaded++;
    _set(_state.copyWith(loaded: _loaded));
  }

  Future<void> retry() async {
    _set(_state.copyWith(
      detail: JobDetail.empty(roleId, 'Current Level'),
      loaded: 0,
      done: false,
      fromCache: false,
      clearError: true,
    ));
    await _generate();
  }

  Map<String, dynamic> _buildProfile(String title) {
    // Load the personalization profile saved at assessment submit.
    Map<String, dynamic> stored = const {};
    final raw = storage.getUserProfileRaw();
    if (raw != null) {
      try {
        stored = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {/* ignore malformed cache */}
    }
    return {
      ...stored,
      'education': stored['education'] ?? '',
      'career_title': title,
      'career_domain': title,
      'strict_domain': true,
      'instruction_institutes':
          'Generate ONLY institutes that offer courses/degrees directly relevant to $title.',
      'instruction_companies': 'Generate ONLY companies that actively hire $title professionals.',
      'instruction_experts': 'Generate ONLY real industry experts who are actual $title professionals.',
    };
  }

  /// Appends a domain hint to the title (compact port of the web `domainQualify`).
  String _domainQualify(String title) {
    final t = title.toLowerCase();
    bool has(String pattern) => RegExp(pattern).hasMatch(t);
    if (has(r'doctor|physician|surgeon|dentist|nurse|pharmac|medical|clinical|healthcare|mbbs|bds|nursing|therap')) {
      return '$title (Medical/Healthcare domain — generate ONLY medical colleges, hospitals, pharma/healthcare companies, and medical professionals as experts)';
    }
    if (has(r'software|engineer|developer|programmer|data scien|machine learning|ai|devops|cloud|cyber|network|full.?stack|frontend|backend|android|ios|web dev|mechanical|civil|electrical|electronics|robotics|iot')) {
      return '$title (Engineering/Technology domain — generate ONLY engineering colleges, tech companies, and technology professionals as experts)';
    }
    if (has(r'accountant|chartered|cfa|finance|banker|investment|auditor|tax|actuar|economist|financial|insurance|commerce')) {
      return '$title (Finance/Commerce domain — generate ONLY finance/commerce institutes, banks/financial firms, and finance professionals as experts)';
    }
    if (has(r'lawyer|advocate|attorney|legal|solicitor|judge|paralegal|llb|llm')) {
      return '$title (Legal domain — generate ONLY law schools, law firms/courts, and legal professionals as experts)';
    }
    if (has(r'designer|graphic|ui.?ux|fashion|interior|architect|animator|illustrator|photographer|filmmaker|journalist|content writer|media|advertising|marketing')) {
      return '$title (Design/Creative/Media domain — generate ONLY design/arts/media institutes, creative agencies, and design professionals as experts)';
    }
    if (has(r'teacher|professor|lecturer|educator|researcher|scientist|academic|phd')) {
      return '$title (Education/Research domain — generate ONLY universities/research institutes and educators/researchers as experts)';
    }
    return '$title (generate ONLY institutes, companies, and experts directly relevant to $title)';
  }
}
