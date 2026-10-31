import 'package:flutter/material.dart';
import 'package:app_ui/theme/app_tokens.dart';

const _seed = Color(0xFF3B6FD4);

ThemeData _build(Brightness brightness) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
  extensions: const [AppTokens.standard],
);

/// Light Material 3 theme; pass it as `theme` of the app widget.
final ThemeData lightTheme = _build(Brightness.light);

/// Dark Material 3 theme; pass it as `darkTheme` of the app widget.
final ThemeData darkTheme = _build(Brightness.dark);
