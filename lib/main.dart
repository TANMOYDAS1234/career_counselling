import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Fire-and-forget warm-up: wake the free-tier backend while the user navigates,
  // so the first AI call (recommendations / module feedback / report) isn't stuck
  // behind a ~50s cold start.
  unawaited(_warmUpBackend());

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const EduBotApp(),
    ),
  );
}

Future<void> _warmUpBackend() async {
  try {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 70),
    ));
    await dio.get('${AppConfig.apiBaseUrl}/health');
  } catch (_) {
    // Best-effort only — ignore failures (offline, endpoint not yet deployed, etc.).
  }
}
