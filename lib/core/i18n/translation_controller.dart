import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_service.dart';
import 'language_controller.dart';

/// In-memory + best-effort batched translation cache for the active language.
///
/// Mirrors the web `TranslatedText` flow: English source strings are translated
/// on demand via `/api/translate-batch`, cached, and re-rendered. `en` is a
/// pass-through (no network). Strings requested within a short window are
/// coalesced into a single batch request.
class TranslationController extends Notifier<Map<String, String>> {
  final Set<String> _pending = {};
  final Set<String> _inFlight = {};
  Timer? _debounce;

  @override
  Map<String, String> build() {
    // Reset the cache whenever the language changes.
    ref.watch(languageProvider);
    ref.onDispose(() => _debounce?.cancel());
    return const {};
  }

  /// Returns the cached translation if present, otherwise schedules a fetch and
  /// returns the original English [text] for now.
  String resolve(String text) {
    final lang = ref.read(languageProvider);
    if (lang == 'en' || text.trim().isEmpty) return text;
    final cached = state[text];
    if (cached != null) return cached;
    if (!_inFlight.contains(text)) {
      _pending.add(text);
      _scheduleFlush();
    }
    return text;
  }

  void _scheduleFlush() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _flush);
  }

  Future<void> _flush() async {
    if (_pending.isEmpty) return;
    final lang = ref.read(languageProvider);
    if (lang == 'en') {
      _pending.clear();
      return;
    }
    final batch = _pending.take(50).toList();
    _pending.removeAll(batch);
    _inFlight.addAll(batch);

    final ApiService api = ref.read(apiServiceProvider);
    try {
      final translations = await api.translateBatch(batch, lang, sourceLanguage: 'en');
      final next = Map<String, String>.from(state);
      for (var i = 0; i < batch.length; i++) {
        if (i < translations.length) next[batch[i]] = translations[i];
      }
      state = next;
    } catch (_) {
      // Leave English in place on failure.
    } finally {
      _inFlight.removeAll(batch);
      if (_pending.isNotEmpty) _scheduleFlush();
    }
  }
}

final translationProvider =
    NotifierProvider<TranslationController, Map<String, String>>(TranslationController.new);
