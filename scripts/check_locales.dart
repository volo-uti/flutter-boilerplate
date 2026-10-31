// Fails when the ARB files of an app (apps/*/lib/l10n) do not share one key set.
// Zero dependencies: run with `dart run scripts/check_locales.dart`.
import 'dart:convert';
import 'dart:io';

Set<String> keysOf(String json) => (jsonDecode(json) as Map<String, dynamic>)
    .keys
    .where((k) => !k.startsWith('@'))
    .toSet();

void main() {
  var bad = false;
  var checked = 0;
  final apps = Directory('apps');
  for (final app
      in apps.existsSync()
          ? apps.listSync().whereType<Directory>()
          : <Directory>[]) {
    final dir = Directory('${app.path}/lib/l10n');
    if (!dir.existsSync()) continue;
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'))
        .toList();
    final keys = {for (final f in files) f.path: keysOf(f.readAsStringSync())};
    final union = keys.values.expand((k) => k).toSet();
    keys.forEach((path, k) {
      final missing = union.difference(k);
      if (missing.isNotEmpty) {
        bad = true;
        stderr.writeln(
          '$path is missing: ${(missing.toList()..sort()).join(', ')}',
        );
      }
    });
    checked += files.length;
  }
  if (bad) exit(1);
  stdout.writeln('Locales OK ($checked ARB files)');
}
