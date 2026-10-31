import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/app_env.dart';
import 'package:app_shared/data/http_client.dart';
import 'package:app_shared/data/http_dio_client.dart';
import 'package:app_shared/data/mock_http_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root: every provider that wires adapters or app-wide state lives here.
final appEnvProvider = Provider<AppEnv>((_) => const AppEnv.fromEnvironment());

final httpClientProvider = Provider<HttpClient>((ref) {
  final env = ref.watch(appEnvProvider);
  if (env.useMocks) return const MockHttpClient();
  return HttpDioClient(Dio(BaseOptions(baseUrl: env.apiBaseUrl)));
});

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Flips against the brightness that is currently shown.
  void toggle(Brightness current) =>
      state = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

/// `null` follows the device locale.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void select(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
