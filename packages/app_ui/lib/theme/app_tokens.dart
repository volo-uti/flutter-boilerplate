import 'package:flutter/material.dart';

/// App-specific design tokens, available via `Theme.of(context).extension<AppTokens>()`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({required this.spacing, required this.radius});

  static const standard = AppTokens(spacing: 16, radius: 12);

  final double spacing;
  final double radius;

  @override
  AppTokens copyWith({double? spacing, double? radius}) => AppTokens(
    spacing: spacing ?? this.spacing,
    radius: radius ?? this.radius,
  );

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      spacing: spacing + (other.spacing - spacing) * t,
      radius: radius + (other.radius - radius) * t,
    );
  }
}
