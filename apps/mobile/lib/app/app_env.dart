/// Build-time configuration read from `--dart-define` / `--dart-define-from-file`.
///
/// Every value has a default so the app runs with no environment at all.
class AppEnv {
  const AppEnv({required this.apiBaseUrl, required this.useMocks});

  /// Reads the compile-time defines.
  const AppEnv.fromEnvironment()
    : apiBaseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.com',
      ),
      useMocks = const bool.fromEnvironment('USE_MOCKS', defaultValue: true);

  final String apiBaseUrl;

  /// When true, composition wires `mock_` adapters instead of `http_` ones.
  final bool useMocks;
}
