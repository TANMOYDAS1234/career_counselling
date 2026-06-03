import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/onboarding_data.dart';
import '../../models/top_career.dart';
import '../providers/core_providers.dart';
import 'api_exception.dart';

/// Typed client for the Flask backend. One method per endpoint, grouped by
/// feature. RPC-style: every call POSTs JSON and reads a `success` flag.
class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(path, data: body);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {'success': false, 'message': 'Unexpected server response.'};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signup(String username, String password) =>
      _post('/signup', {'username': username, 'password': password});

  Future<Map<String, dynamic>> login(String username, String password) =>
      _post('/login', {'username': username, 'password': password});

  Future<void> logout(String username) => _post('/logout', {'username': username});

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) =>
      _post('/api/update-profile', body);

  // ── Onboarding (stage 0) ────────────────────────────────────────────────
  Future<OnboardingData?> getOnboarding(String username) async {
    final res = await _post('/api/get-onboarding', {'username': username});
    if (res['success'] == true && res['data'] is Map) {
      return OnboardingData.fromJson(Map<String, dynamic>.from(res['data'] as Map));
    }
    return null;
  }

  Future<bool> saveOnboarding(String username, OnboardingData data) async {
    final res = await _post('/api/save-onboarding', {'username': username, ...data.toJson()});
    return res['success'] == true;
  }

  // ── Assessment ─────────────────────────────────────────────────────────
  /// [questionnaireData] keys must match the backend `user_session` fields
  /// (see [QuestionnaireData] for the canonical shape).
  Future<bool> saveQuestionnaire(String username, Map<String, dynamic> questionnaireData) async {
    final res = await _post('/api/save-questionnaire', {
      'username': username,
      'questionnaireData': questionnaireData,
    });
    return res['success'] == true;
  }

  Future<String?> generateModuleFeedback(int moduleNumber, String answersSoFarJson) async {
    final res = await _post('/api/generate-module-feedback', {
      'module_number': moduleNumber,
      'answers_so_far': answersSoFarJson,
    });
    if (res['success'] == true) return res['feedback'] as String?;
    return null;
  }

  // ── Recommendations ───────────────────────────────────────────────────────
  Future<List<TopCareer>> getTop3Careers(String username) async {
    final res = await _post('/api/get-top-3-careers', {'username': username});
    if (res['success'] == true && res['careers'] is List) {
      return (res['careers'] as List)
          .whereType<Map>()
          .map((e) => TopCareer.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  // ── Mindset report ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getMindsetReport(String username) async {
    final res = await _post('/api/get-mindset-report', {'username': username});
    if (res['success'] == true && res['report'] is Map) {
      return Map<String, dynamic>.from(res['report'] as Map);
    }
    return null;
  }

  // ── Job-role details (per-section AI generation) ───────────────────────────
  Future<Map<String, dynamic>?> careerDetails({
    required String careerTitle,
    required String sectionType,
    required Map<String, dynamic> profile,
  }) async {
    final res = await _post('/api/career-details', {
      'career_title': careerTitle,
      'section_type': sectionType,
      'profile': profile,
    });
    if (res['success'] == true && res['content'] is Map) {
      return Map<String, dynamic>.from(res['content'] as Map);
    }
    return null;
  }

  Future<bool> saveJobRole({
    required String username,
    required String roleId,
    required String roleTitle,
    required Map<String, dynamic> detailData,
  }) async {
    final res = await _post('/api/save-job-role', {
      'username': username,
      'roleId': roleId,
      'roleTitle': roleTitle,
      'detailData': detailData,
    });
    return res['success'] == true;
  }

  Future<Map<String, dynamic>?> loadJobRole(String username, String roleId) async {
    final res = await _post('/api/load-job-role', {'username': username, 'roleId': roleId});
    if (res['success'] == true && res['detail'] is Map) {
      return Map<String, dynamic>.from(res['detail'] as Map);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getRecentJobRole(String username) async {
    final res = await _post('/api/get-recent-job-role', {'username': username});
    if (res['success'] == true && res['jobRole'] is Map) {
      return Map<String, dynamic>.from(res['jobRole'] as Map);
    }
    return null;
  }

  // ── Translation ───────────────────────────────────────────────────────────
  Future<String> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    final res = await _post('/api/translate', {
      'text': text,
      'target_language': targetLanguage,
      'source_language': ?sourceLanguage,
    });
    return (res['translated_text'] as String?) ?? text;
  }

  Future<List<String>> translateBatch(List<String> texts, String targetLanguage,
      {String? sourceLanguage}) async {
    final res = await _post('/api/translate-batch', {
      'texts': texts,
      'target_language': targetLanguage,
      'source_language': ?sourceLanguage,
    });
    if (res['translations'] is List) {
      return (res['translations'] as List).map((e) => e.toString()).toList();
    }
    return texts;
  }

  // ── PDF ─────────────────────────────────────────────────────────────────
  /// Generates the career-report PDF on the backend (Playwright) and returns
  /// the raw bytes. [detailData] is the normalized job-detail map
  /// ([JobDetail.toJson]); the backend renders it via its report template.
  Future<Uint8List> generatePdf({
    required String roleId,
    required String roleTitle,
    required String targetLanguage,
    required Map<String, dynamic> detailData,
  }) async {
    try {
      final res = await _dio.post(
        '/api/generate-pdf',
        data: {
          'roleId': roleId,
          'roleTitle': roleTitle,
          'targetLanguage': targetLanguage,
          'translatedData': detailData,
        },
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      if (data is List<int>) return Uint8List.fromList(data);
      if (data is Uint8List) return data;
      throw const ApiException('The server did not return a PDF.');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(ref.watch(dioProvider)),
);
