import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../models/top_career.dart';
import '../auth/auth_controller.dart';

/// Loads the user's top-3 career matches, preferring the local cache
/// (mirrors the web `careerRecommendations` sessionStorage cache).
class RecommendationsController extends AsyncNotifier<List<TopCareer>> {
  ApiService get _api => ref.read(apiServiceProvider);

  @override
  Future<List<TopCareer>> build() async {
    final storage = ref.read(localStorageProvider);
    final username = ref.read(authControllerProvider).user?.email ?? storage.username;

    // 1) Cache hit.
    final cached = storage.getRecommendationsRaw();
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached);
        final careers = (decoded is Map ? decoded['careers'] : decoded) as List?;
        if (careers != null && careers.isNotEmpty) {
          return careers
              .whereType<Map>()
              .map((e) => TopCareer.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (_) {/* fall through to network */}
    }

    if (username == null || username.isEmpty) return [];

    // 2) Fetch + cache.
    final careers = await _api.getTop3Careers(username);
    if (careers.isNotEmpty) {
      await storage.setRecommendationsRaw(
        jsonEncode({'careers': careers.map((c) => c.toJson()).toList()}),
      );
    }
    return careers;
  }

  /// Clears the cache and reloads (used by "Retake Assessment").
  Future<void> refreshFromServer() async {
    await ref.read(localStorageProvider).clearAssessmentCache();
    ref.invalidateSelf();
    await future;
  }
}

final recommendationsControllerProvider =
    AsyncNotifierProvider<RecommendationsController, List<TopCareer>>(
  RecommendationsController.new,
);
