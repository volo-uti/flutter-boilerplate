// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Boilerplate';

  @override
  String get homeTitle => 'Hello, world';

  @override
  String get homeBody => 'Edit lib/features/home to get started.';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get switchLanguage => 'Switch language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => 'Korean';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String notFoundBody(String path) {
    return 'No route matches $path.';
  }

  @override
  String get goHome => 'Go home';
}
