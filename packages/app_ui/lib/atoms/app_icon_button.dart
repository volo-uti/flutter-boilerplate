import 'package:flutter/material.dart';

/// Icon button that always carries a tooltip, which doubles as its semantic label.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
}
