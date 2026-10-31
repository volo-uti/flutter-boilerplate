import 'package:app_ui/atoms/app_icon_button.dart';
import 'package:flutter/material.dart';

/// Button that flips between light and dark. [tooltip] is the localized label.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppIconButton(
      icon: isDark ? Icons.light_mode : Icons.dark_mode,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
