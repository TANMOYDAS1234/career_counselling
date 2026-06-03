import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';

/// Supported UI languages and their display names (matches the web app).
const Map<String, String> kSupportedLanguages = {
  'en': 'English',
  'hi': 'हिन्दी',
  'bn': 'বাংলা',
};

/// Holds the currently selected language code, persisted to local storage
/// (mirrors the web `edubot_language` key).
class LanguageController extends Notifier<String> {
  @override
  String build() => ref.read(localStorageProvider).getLanguage();

  Future<void> setLanguage(String code) async {
    if (!kSupportedLanguages.containsKey(code) || code == state) return;
    await ref.read(localStorageProvider).setLanguage(code);
    state = code;
  }
}

final languageProvider = NotifierProvider<LanguageController, String>(LanguageController.new);
