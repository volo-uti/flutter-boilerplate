import 'package:flutter/material.dart';
import 'package:mobile/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: App()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the home page with header controls', (tester) async {
    await _pump(tester);
    expect(find.text('Hello, world'), findsOneWidget);
    expect(find.byTooltip('Toggle theme'), findsOneWidget);
    expect(find.byTooltip('Switch language'), findsOneWidget);
  });

  testWidgets('theme toggle flips brightness', (tester) async {
    await _pump(tester);
    final before = Theme.of(tester.element(find.text('Hello, world')))
        .brightness;
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();
    final after = Theme.of(tester.element(find.text('Hello, world')))
        .brightness;
    expect(after, isNot(before));
  });

  testWidgets('locale switcher changes the language', (tester) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Switch language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Korean').last);
    await tester.pumpAndSettle();
    expect(find.text('Hello, world'), findsNothing);
    expect(find.byTooltip('Switch language'), findsNothing);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
