import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:app_ui/theme/app_tokens.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.homeTitle, style: text.headlineMedium),
            SizedBox(height: tokens.spacing / 2),
            Text(
              l10n.homeBody,
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
