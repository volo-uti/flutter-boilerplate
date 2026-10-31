import 'package:flutter/material.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/app/router.dart';
import 'package:app_ui/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: ref.watch(themeModeProvider),
    locale: ref.watch(localeProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: ref.watch(routerProvider),
  );
}
