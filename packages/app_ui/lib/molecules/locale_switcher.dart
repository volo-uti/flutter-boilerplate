import 'package:flutter/material.dart';

/// One selectable language: the locale and its display label.
class LocaleOption {
  const LocaleOption(this.locale, this.label);

  final Locale locale;
  final String label;
}

/// Menu that lists [options] and reports the chosen locale.
class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({
    required this.options,
    required this.tooltip,
    required this.onSelected,
    super.key,
  });

  final List<LocaleOption> options;
  final String tooltip;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<Locale>(
    icon: const Icon(Icons.language),
    tooltip: tooltip,
    onSelected: onSelected,
    itemBuilder: (_) => [
      for (final o in options)
        PopupMenuItem(value: o.locale, child: Text(o.label)),
    ],
  );
}
