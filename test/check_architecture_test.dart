// Imports the script by relative path: scripts/ is outside any lib/, so it has
// no package: URI.
import 'package:flutter_test/flutter_test.dart';

import '../scripts/check_architecture.dart';

const _apps = {'mobile', 'admin'};
const _packages = {'app_ui', 'app_shared', 'billing'};

const _presentation = 'apps/mobile/lib/features/a/presentation/p.dart';
const _application = 'apps/mobile/lib/features/a/application/u.dart';
const _data = 'apps/mobile/lib/features/a/data/r.dart';
const _domain = 'apps/mobile/lib/features/a/domain/e.dart';
const _root = 'apps/mobile/lib/app/router.dart';
const _ui = 'packages/app_ui/lib/atoms/b.dart';
const _sharedDomain = 'packages/app_shared/lib/domain/result.dart';
const _sharedData = 'packages/app_shared/lib/data/c.dart';
const _billingDomain = 'packages/billing/lib/domain/invoice.dart';
const _billingUi = 'packages/billing/lib/presentation/page.dart';

List<String> _run(String path, String import) =>
    violations(path, "import '$import';\n", _apps, _packages);

void main() {
  group('allowed', () {
    final cases = {
      _presentation: [
        'package:mobile/features/a/application/u.dart',
        'package:mobile/features/a/domain/e.dart',
        'package:mobile/l10n/app_localizations.dart',
        'package:app_ui/atoms/b.dart',
        'package:app_shared/domain/result.dart',
        'package:flutter/material.dart',
      ],
      _application: [
        'package:mobile/features/a/domain/e.dart',
        'package:app_shared/domain/result.dart',
      ],
      _data: [
        'package:mobile/features/a/domain/e.dart',
        'package:app_shared/data/http_client.dart',
        'package:dio/dio.dart',
      ],
      _domain: [
        'dart:async',
        'package:app_shared/domain/result.dart',
        'e2.dart',
      ],
      _root: [
        'package:mobile/features/a/data/r.dart',
        'package:app_ui/atoms/b.dart',
        'package:billing/presentation/page.dart',
      ],
      _ui: [
        'package:app_shared/domain/result.dart',
        'package:flutter/material.dart',
      ],
      _sharedData: [
        'package:app_shared/domain/result.dart',
        'package:dio/dio.dart',
      ],
      _billingDomain: ['package:app_shared/domain/result.dart'],
      _billingUi: [
        'package:billing/domain/invoice.dart',
        'package:app_ui/atoms/b.dart',
      ],
    };
    cases.forEach((path, imports) {
      for (final i in imports) {
        test('$path -> $i', () => expect(_run(path, i), isEmpty));
      }
    });
  });

  group('rejected', () {
    final cases = {
      _domain: [
        'package:mobile/features/a/data/r.dart',
        'package:flutter/material.dart',
        'package:dio/dio.dart',
        'package:flutter_riverpod/flutter_riverpod.dart',
        'dart:ui',
        'package:app_shared/data/http_client.dart',
      ],
      _application: [
        'package:mobile/features/a/data/r.dart',
        'package:mobile/features/a/presentation/p.dart',
        'package:app_ui/atoms/b.dart',
      ],
      _data: ['package:mobile/features/a/application/u.dart'],
      _presentation: [
        'package:mobile/features/a/data/r.dart',
        'package:mobile/features/b/domain/e.dart',
        'package:mobile/app/router.dart',
        'package:admin/app/router.dart',
        'package:billing/domain/invoice.dart',
      ],
      _root: ['package:admin/app/app.dart'],
      _ui: [
        'package:mobile/app/router.dart',
        'package:billing/domain/invoice.dart',
      ],
      _sharedDomain: [
        'package:app_shared/data/c.dart',
        'package:app_ui/atoms/b.dart',
        'package:flutter/foundation.dart',
      ],
      _sharedData: [
        'package:app_ui/atoms/b.dart',
        'package:mobile/app/app.dart',
      ],
      _billingDomain: [
        'package:billing/data/x.dart',
        'package:mobile/app/app.dart',
      ],
      _billingUi: ['package:mobile/app/app.dart'],
    };
    cases.forEach((path, imports) {
      for (final i in imports) {
        test('$path -> $i', () => expect(_run(path, i), hasLength(1)));
      }
    });

    test('reports file and line', () {
      final out = violations(
        _ui,
        "\nexport 'package:mobile/app/app.dart';\n",
        _apps,
        _packages,
      );
      expect(out.single, startsWith('$_ui:2:'));
    });

    test('catches relative imports', () {
      expect(_run(_domain, '../data/r.dart'), hasLength(1));
    });
  });

  group('constraintConflicts', () {
    test('accepts equal constraints and workspace members', () {
      expect(
        constraintConflicts({
          'a': 'dependencies:\n  dio: ^5.0.0\n  app_ui: any\n',
          'b': 'dependencies:\n  dio: ^5.0.0\n  app_ui: any\n',
        }),
        isEmpty,
      );
    });

    test('flags different constraints for one package', () {
      final out = constraintConflicts({
        'a': 'dependencies:\n  dio: ^5.0.0\n',
        'b': 'dev_dependencies:\n  dio: ^5.1.0\n',
      });
      expect(out.single, contains('dio'));
    });
  });

  group('raw widgets', () {
    List<String> raw(String path, String code) =>
        violations(path, code, _apps, _packages);

    test('IconButton outside app_ui is reported with its replacement', () {
      final found = raw(
        _presentation,
        'final w = IconButton(onPressed: null);',
      );
      expect(found, hasLength(1));
      expect(
        found.single,
        contains(
          'Use AppIconButton from package:app_ui/atoms/app_icon_button.dart',
        ),
      );
    });

    test('named constructors are reported', () {
      for (final c in ['filled', 'outlined', 'filledTonal']) {
        expect(
          raw(_presentation, 'final w = IconButton.$c(icon: i);'),
          hasLength(1),
        );
      }
    });

    test('AppIconButton is not reported', () {
      expect(raw(_presentation, 'final w = AppIconButton(icon: i);'), isEmpty);
    });

    test('files inside app_ui are exempt', () {
      expect(raw(_ui, 'final w = IconButton(onPressed: null);'), isEmpty);
    });
  });

  group('library gaps', () {
    test('markers are listed with file and line', () {
      const text = 'final a = 1;\n  // TODO(library: 4px line) tried style\n';
      expect(libraryGaps(_ui, text), [
        '$_ui:2: // TODO(library: 4px line) tried style',
      ]);
    });

    test('other comments are ignored', () {
      expect(libraryGaps(_ui, '// TODO(me): later\n// library\n'), isEmpty);
    });
  });
}
