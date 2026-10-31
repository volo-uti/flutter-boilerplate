// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '플러터 보일러플레이트';

  @override
  String get homeTitle => '안녕하세요';

  @override
  String get homeBody => '시작하려면 lib/features/home 을 수정하세요.';

  @override
  String get toggleTheme => '테마 전환';

  @override
  String get switchLanguage => '언어 전환';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageKorean => '한국어';

  @override
  String get notFoundTitle => '페이지를 찾을 수 없습니다';

  @override
  String notFoundBody(String path) {
    return '$path 경로와 일치하는 화면이 없습니다.';
  }

  @override
  String get goHome => '홈으로';
}
