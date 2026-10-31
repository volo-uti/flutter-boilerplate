import 'package:flutter/material.dart';

/// Page frame: a header above the page body.
class AppShell extends StatelessWidget {
  const AppShell({required this.header, required this.body, super.key});

  final PreferredSizeWidget header;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: header,
    body: SafeArea(child: body),
  );
}
