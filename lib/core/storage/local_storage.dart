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

  // ── Recommendations cache (raw JSON string) ───────────────────────────────
  String? getRecommendationsRaw() => _prefs.getString(_kRecommendations);
  Future<void> setRecommendationsRaw(String json) =>
      _prefs.setString(_kRecommendations, json);

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
