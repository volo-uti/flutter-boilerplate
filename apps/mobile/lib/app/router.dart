import 'package:flutter/material.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/features/home/presentation/home_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:app_ui/molecules/locale_switcher.dart';
import 'package:app_ui/organisms/app_header.dart';
import 'package:app_ui/templates/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const _Framed(child: HomePage()),
      ),
    ],
    errorBuilder: (_, state) =>
        _Framed(child: _NotFound(path: state.uri.toString())),
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Wraps a page in the shared shell, wired to the app-wide state.
class _Framed extends ConsumerWidget {
  const _Framed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppShell(
      header: AppHeader(
        title: l10n.appTitle,
        themeToggleTooltip: l10n.toggleTheme,
        onToggleTheme: () => ref
            .read(themeModeProvider.notifier)
            .toggle(Theme.of(context).brightness),
        localeTooltip: l10n.switchLanguage,
        localeOptions: [
          LocaleOption(const Locale('en'), l10n.languageEnglish),
          LocaleOption(const Locale('ko'), l10n.languageKorean),
        ],
        onSelectLocale: ref.read(localeProvider.notifier).select,
      ),
      body: child,
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.notFoundTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.notFoundBody(path)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/'),
            child: Text(l10n.goHome),
          ),
        ],
      ),
    );
  }
}
