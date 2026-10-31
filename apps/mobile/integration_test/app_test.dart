import 'package:flutter/material.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/features/home/presentation/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Locale-independent: the device may run in any language.
  testWidgets('app boots to the home page', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    final context = tester.element(find.byType(HomePage));
    final before = Theme.of(context).brightness;
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      isNot(before),
    );
  });
}
