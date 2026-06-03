import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/storage/local_storage.dart';
import '../../models/app_user.dart';

/// Immutable auth state. [bootstrapped] flips true once the initial
/// localStorage read completes.
class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
    this.bootstrapped = false,
  });

  final AppUser? user;
  final bool loading;
  final String? error;
  final bool bootstrapped;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? bootstrapped,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      bootstrapped: bootstrapped ?? this.bootstrapped,
    );
  }
}

/// Mirrors the web `useSession` hook: restore the persisted user on start,
/// and expose login / signup / logout.
class AuthController extends Notifier<AuthState> {
  late final ApiService _api = ref.read(apiServiceProvider);
  late final LocalStorage _storage = ref.read(localStorageProvider);

  @override
  AuthState build() {
    final user = _storage.getUser();
    return AuthState(user: user, bootstrapped: true);
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> login(String username, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _api.login(username, password);
      if (result['success'] == true) {
        final session = result['session'] as Map?;
        // The Flask backend returns name/profileImage at the top level; the
        // (newer) session object is preferred when present.
        final user = AppUser(
          email: username,
          name: (session?['name'] as String?) ?? (result['name'] as String?) ?? username,
          profileImage: (session?['profileImage'] as String?) ?? (result['profileImage'] as String?),
        );
        await _storage.setUser(user);
        await _cacheSession(session);
        state = state.copyWith(user: user, loading: false);
        return true;
      }
      state = state.copyWith(loading: false, error: (result['message'] as String?) ?? 'Login failed.');
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    }
  }

  Future<bool> signup(String username, String password, {String? name}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _api.signup(username, password);
      if (result['success'] == true) {
        final displayName = (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : username.split('@').first;
        final user = AppUser(email: username, name: displayName);
        await _storage.setUser(user);
        state = state.copyWith(user: user, loading: false);
        return true;
      }
      state = state.copyWith(loading: false, error: (result['message'] as String?) ?? 'Sign up failed.');
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    final email = state.user?.email;
    if (email != null) {
      try {
        await _api.logout(email);
      } catch (_) {
        // Proceed with local logout even if the API call fails.
      }
    }
    await _storage.clearAll();
    state = const AuthState(bootstrapped: true);
  }

  /// Applies a locally-edited profile (name / image) to state + storage,
  /// after a successful `/api/update-profile` call.
  Future<void> applyProfile({String? name, String? profileImage}) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(name: name, profileImage: profileImage);
    await _storage.setUser(updated);
    state = state.copyWith(user: updated);
  }

  Future<void> _cacheSession(Map? session) async {
    if (session == null) return;
    if (session['recommendations'] != null) {
      await _storage.setRecommendationsRaw(jsonEncode(session['recommendations']));
    }
    if (session['lastRole'] != null) {
      await _storage.setLastRoleRaw(jsonEncode(session['lastRole']));
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
