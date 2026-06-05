import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';

/// Thin wrapper over SharedPreferences that mirrors the web app's
/// localStorage/sessionStorage keys (edubot_user, careerRecommendations, etc.)
/// so the persisted data model stays consistent with the existing backend.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kUser = 'edubot_user';
  static const _kUsername = 'username';
  static const _kLanguage = 'edubot_language';
  static const _kRecommendations = 'careerRecommendations';
  static const _kLastRole = 'edubot_last_role';
  static const _kJobDetailPrefix = 'jobDetail_';

  // ── User ────────────────────────────────────────────────────────────────
  AppUser? getUser() {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> setUser(AppUser user) async {
    await _prefs.setString(_kUser, jsonEncode(user.toJson()));
    await _prefs.setString(_kUsername, user.email);
  }

  String? get username => _prefs.getString(_kUsername) ?? getUser()?.email;

  // ── Language ────────────────────────────────────────────────────────────
  String getLanguage() => _prefs.getString(_kLanguage) ?? 'en';
  Future<void> setLanguage(String code) => _prefs.setString(_kLanguage, code);

  // ── Translation cache (per language, persisted) ───────────────────────────
  static const _kTrPrefix = 'edubot_tr_';

  Map<String, String> getTranslations(String lang) {
    final raw = _prefs.getString('$_kTrPrefix$lang');
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> setTranslations(String lang, Map<String, String> map) =>
      _prefs.setString('$_kTrPrefix$lang', jsonEncode(map));

  // ── Recommendations cache (raw JSON string) ───────────────────────────────
  String? getRecommendationsRaw() => _prefs.getString(_kRecommendations);
  Future<void> setRecommendationsRaw(String json) =>
      _prefs.setString(_kRecommendations, json);

  // ── User profile (assessment context for AI personalization) ───────────────
  static const _kUserProfile = 'userProfile';
  String? getUserProfileRaw() => _prefs.getString(_kUserProfile);
  Future<void> setUserProfileRaw(String json) =>
      _prefs.setString(_kUserProfile, json);

  // ── Job-detail cache, keyed by roleId ──────────────────────────────────────
  String? getJobDetailRaw(String roleId) =>
      _prefs.getString('$_kJobDetailPrefix$roleId');
  Future<void> setJobDetailRaw(String roleId, String json) =>
      _prefs.setString('$_kJobDetailPrefix$roleId', json);

  // ── Last viewed role ────────────────────────────────────────────────────
  String? getLastRoleRaw() => _prefs.getString(_kLastRole);
  Future<void> setLastRoleRaw(String json) => _prefs.setString(_kLastRole, json);

  /// Clears all per-user data on logout (keeps language preference).
  Future<void> clearAll() async {
    final keep = _prefs.getString(_kLanguage);
    final keys = _prefs.getKeys().toList();
    for (final k in keys) {
      if (k == _kLanguage) continue;
      await _prefs.remove(k);
    }
    if (keep != null) await _prefs.setString(_kLanguage, keep);
  }

  /// Clears just the cached recommendations + job details (used on "Retake").
  Future<void> clearAssessmentCache() async {
    await _prefs.remove(_kRecommendations);
    for (final k in _prefs.getKeys().where((k) => k.startsWith(_kJobDetailPrefix))) {
      await _prefs.remove(k);
    }
  }
}
