import 'package:app_ui/molecules/locale_switcher.dart';
import 'package:app_ui/molecules/theme_toggle.dart';
import 'package:flutter/material.dart';

/// Top bar with a title, theme toggle and locale switcher.
/// All labels are passed in already localized.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    required this.themeToggleTooltip,
    required this.onToggleTheme,
    required this.localeTooltip,
    required this.localeOptions,
    required this.onSelectLocale,
    super.key,
  });

  final String title;
  final String themeToggleTooltip;
  final VoidCallback onToggleTheme;
  final String localeTooltip;
  final List<LocaleOption> localeOptions;
  final ValueChanged<Locale> onSelectLocale;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title),
    actions: [
      ThemeToggle(tooltip: themeToggleTooltip, onPressed: onToggleTheme),
      LocaleSwitcher(
        options: localeOptions,
        tooltip: localeTooltip,
        onSelected: onSelectLocale,
      ),
    ],
  );
}
