// Reports the newest stable Flutter and outdated direct dependencies.
// Run through `scripts/update-check`. Exit 0 when a report was produced,
// non-zero only when a check itself failed.
import 'dart:convert';
import 'dart:io';

const _staleAfter = Duration(days: 365);

Future<Object?> _getJson(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    return jsonDecode(await response.transform(utf8.decoder).join());
  } finally {
    client.close();
  }
}

Future<void> _flutter() async {
  final pinned =
      (jsonDecode(File('.fvmrc').readAsStringSync())
              as Map<String, dynamic>)['flutter']
          as String;
  final data = await _getJson(
    'https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json',
  ) as Map<String, dynamic>;
  final hash = (data['current_release'] as Map<String, dynamic>)['stable'];
  final releases = (data['releases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final latest = releases.firstWhere((r) => r['hash'] == hash);
  final version = latest['version'] as String;
  stdout.writeln('Flutter');
  stdout.writeln(
    '  pinned $pinned, latest stable $version'
    '${pinned == version ? ' (up to date)' : ' (UPDATE AVAILABLE)'}',
  );
}

Future<Map<String, dynamic>> _dartJson(List<String> args, {String? dir}) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    args,
    workingDirectory: dir,
  );
  if (result.exitCode != 0) {
    throw ProcessException('dart', args, '${result.stderr}');
  }
  return jsonDecode(result.stdout as String) as Map<String, dynamic>;
}

Future<void> _dependencies() async {
  // Direct and dev dependencies of every workspace member, de-duplicated.
  final members = [
    '.',
    for (final parent in ['apps', 'packages'])
      if (Directory(parent).existsSync())
        for (final d in Directory(parent).listSync().whereType<Directory>())
          if (File('${d.path}/pubspec.yaml').existsSync()) d.path,
  ];
  // `pub deps` is workspace-wide, so member pubspecs say which are direct.
  final names = <String>{};
  for (final dir in members) {
    var inDeps = false;
    for (final line in File('$dir/pubspec.yaml').readAsLinesSync()) {
      if (RegExp(r'^\S').hasMatch(line)) {
        inDeps =
            line.startsWith('dependencies:') ||
            line.startsWith('dev_dependencies:');
        continue;
      }
      final m = RegExp(r'^  ([a-z0-9_]+):').firstMatch(line);
      if (inDeps && m != null) names.add(m.group(1)!);
    }
  }
  final all =
      ((await _dartJson(['pub', 'deps', '--json']))['packages']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final direct = all
      .where((p) => names.contains(p['name']) && p['source'] == 'hosted')
      .toList();
  // `pub outdated` lists only packages that are behind.
  final outdated = {
    for (final p
        in (await _dartJson(['pub', 'outdated', '--json']))['packages']
            as List<dynamic>)
      (p as Map<String, dynamic>)['package'] as String: p,
  };
  stdout.writeln('\nDirect dependencies');
  for (final p in direct) {
    final name = p['name'] as String;
    final current = p['version'] as String;
    final behind = outdated[name];
    final latest =
        (behind?['latest'] as Map<String, dynamic>?)?['version'] ?? current;
    final upgradable =
        (behind?['upgradable'] as Map<String, dynamic>?)?['version'];
    final flags = <String>[];
    if (latest != current) {
      flags.add(latest == upgradable ? 'update' : 'update (major or blocked)');
    }
    final info = await _getJson(
      'https://pub.dev/api/packages/$name',
    ) as Map<String, dynamic>;
    final published = DateTime.parse(
      (info['latest'] as Map<String, dynamic>)['published'] as String,
    );
    if (DateTime.now().difference(published) > _staleAfter) {
      flags.add(
        'REVISIT (latest release ${published.toIso8601String().substring(0, 10)})',
      );
    }
    stdout.writeln(
      '  $name $current -> $latest'
      '${flags.isEmpty ? '  ok' : '  ${flags.join(', ')}'}',
    );
  }
}

Future<void> main() async {
  try {
    await _flutter();
    await _dependencies();
  } on Object catch (e) {
    stderr.writeln('update-check failed: $e');
    exit(1);
  }
}
