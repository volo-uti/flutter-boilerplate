// Verifies the workspace architecture rules. Zero dependencies:
// run with `dart run scripts/check_architecture.dart`.
//
// 1. Import rules: scans import/export lines under apps/*/lib and
//    packages/*/lib (see AGENTS.md for the rules).
// 2. Dependency consistency: a package declared in several member pubspecs
//    must use the same constraint everywhere.
//
// 3. Reuse: raw Flutter widgets that have an app_ui replacement are rejected
//    outside app_ui (see [rawWidgets]).
// 4. Library gaps: `TODO(library: ...)` markers are listed, never failed (see
//    [libraryGaps]).
//
// Rules are generic: new apps and packages are picked up from the folders.
import 'dart:io';

final _libraryGap = RegExp(r'//\s*TODO\(library:.*');

final _directive = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');
const _impureDart = {'ui', 'io', 'html', 'js', 'js_interop', 'js_util', 'ffi'};

/// Raw Flutter widget -> (replacement, import path in app_ui). A new app_ui
/// widget that replaces a raw one adds one entry here.
const rawWidgets = {
  'IconButton': ('AppIconButton', 'package:app_ui/atoms/app_icon_button.dart'),
};

/// Where a file lives. [kind] is `app` or `pkg`; [owner] is the folder name
/// (= package name); [module] is the feature (apps) or package (packages);
/// [layer] is the layer, `l10n`, `root`, or an app_ui / app_shared folder.
class Loc {
  const Loc(this.kind, this.owner, this.module, this.layer);

  final String kind;
  final String owner;
  final String module;
  final String layer;

  bool get isDomain => layer == 'domain';

  /// Packages that are not app_ui / app_shared are shared features.
  bool get isFeaturePkg =>
      kind == 'pkg' && owner != 'app_ui' && owner != 'app_shared';

  /// `apps/x/lib/a/b.dart` -> Loc, or null when outside any lib/.
  static Loc? parse(String path) {
    final s = path.split('/');
    if (s.length < 4 || s[2] != 'lib') return null;
    final inner = s.sublist(3);
    if (s[0] == 'apps') {
      if (inner.first == 'features' && inner.length > 3) {
        return Loc('app', s[1], inner[1], inner[2]);
      }
      return Loc('app', s[1], '', inner.first == 'l10n' ? 'l10n' : 'root');
    }
    if (s[0] == 'packages' && inner.length > 1) {
      return Loc('pkg', s[1], s[1], inner.first);
    }
    return null;
  }
}

/// Returns a message per rule broken by [source], located at [path] (relative
/// to the repo root, `/` separators). [apps] / [packages] are the folder names.
List<String> violations(
  String path,
  String source,
  Set<String> apps,
  Set<String> packages,
) {
  final from = Loc.parse(path);
  if (from == null) return const [];
  final found = <String>[];
  final lines = source.split('\n');
  if (!(from.kind == 'pkg' && from.owner == 'app_ui')) {
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trimLeft().startsWith('//')) continue;
      for (final e in rawWidgets.entries) {
        if (RegExp('\\b${e.key}(?:\\.\\w+)?\\(').hasMatch(lines[i])) {
          final (name, import) = e.value;
          found.add(
            '$path:${i + 1}: Use $name from $import (see the index in '
            'AGENTS.md).',
          );
        }
      }
    }
  }
  for (var i = 0; i < lines.length; i++) {
    final m = _directive.firstMatch(lines[i]);
    if (m == null) continue;
    final reason = _check(path, from, m.group(1)!, apps, packages);
    if (reason != null) {
      found.add('$path:${i + 1}: $reason (${m.group(1)})');
    }
  }
  return found;
}

String? _check(
  String path,
  Loc from,
  String uri,
  Set<String> apps,
  Set<String> packages,
) {
  final domainLike = from.isDomain && (from.kind == 'pkg' || from.module != '');
  if (uri.startsWith('dart:')) {
    final lib = uri.substring(5).split('/').first;
    return domainLike && _impureDart.contains(lib)
        ? 'domain must be pure Dart'
        : null;
  }

  // Resolve to a repo-relative path when the target is in the workspace.
  String? target;
  if (uri.startsWith('package:')) {
    final rest = uri.substring('package:'.length);
    final name = rest.split('/').first;
    if (apps.contains(name)) {
      target = 'apps/$name/lib/${rest.substring(name.length + 1)}';
    } else if (packages.contains(name)) {
      target = 'packages/$name/lib/${rest.substring(name.length + 1)}';
    }
  } else if (!uri.contains(':')) {
    final out = <String>[];
    for (final p in [...path.split('/')..removeLast(), ...uri.split('/')]) {
      if (p == '..') {
        if (out.isNotEmpty) out.removeLast();
      } else if (p != '.') {
        out.add(p);
      }
    }
    target = out.join('/');
  }
  if (target == null) {
    return domainLike ? 'domain must not depend on external packages' : null;
  }
  final to = Loc.parse(target);
  if (to == null) return null;

  if (to.kind == 'app' && !(from.kind == 'app' && from.owner == to.owner)) {
    return from.kind == 'app'
        ? 'an app must not import another app'
        : 'packages must not import apps';
  }

  // Domain is pure: its own domain and app_shared/domain only.
  if (domainLike) {
    final ownDomain =
        to.isDomain &&
        to.kind == from.kind &&
        to.owner == from.owner &&
        to.module == from.module;
    final sharedDomain =
        to.kind == 'pkg' && to.owner == 'app_shared' && to.layer == 'domain';
    return ownDomain || sharedDomain
        ? null
        : 'domain may only import its own domain and app_shared/domain';
  }
  if (from.kind == 'pkg' && from.owner == 'app_shared') {
    return to.owner == 'app_shared'
        ? null
        : 'app_shared must not import ${to.owner}';
  }
  if (from.kind == 'pkg' && from.owner == 'app_ui') {
    return to.owner == 'app_ui' || to.owner == 'app_shared'
        ? null
        : 'app_ui may only import app_shared';
  }
  if (from.kind == 'app' && from.module == '') {
    // lib/main.dart, lib/app (composition root) and lib/l10n.
    return null;
  }

  // Layered code: an app feature or a shared-feature package.
  if (to.kind == from.kind && to.owner == from.owner) {
    if (to.layer == 'root') return 'only app/ may depend on app/';
    if (to.layer == 'l10n') {
      return from.layer == 'presentation'
          ? null
          : '${from.layer} must not import l10n';
    }
    if (to.module != from.module) {
      return 'a feature must not import another feature';
    }
  } else if (to.isFeaturePkg) {
    return 'a feature must not import another feature';
  }
  if (to.kind == from.kind && to.owner == from.owner) {
    final ok = switch (from.layer) {
      'presentation' => {'presentation', 'application', 'domain'},
      'application' => {'application', 'domain'},
      'data' => {'data', 'domain'},
      _ => <String>{},
    };
    return ok.contains(to.layer)
        ? null
        : '${from.layer} must not import ${to.layer}';
  }
  final okShared = switch (from.layer) {
    'presentation' => {
      'domain',
      'data',
      'atoms',
      'molecules',
      'organisms',
      'templates',
      'theme',
    },
    'application' => {'domain'},
    'data' => {'domain', 'data'},
    _ => <String>{},
  };
  return okShared.contains(to.layer)
      ? null
      : '${from.layer} must not import ${to.owner}/${to.layer}';
}

/// Lines `  name: constraint` of the dependency sections of a pubspec.
Map<String, String> constraintsOf(String pubspec) {
  final out = <String, String>{};
  var inDeps = false;
  for (final line in pubspec.split('\n')) {
    if (RegExp(r'^\S').hasMatch(line)) {
      inDeps =
          line.startsWith('dependencies:') ||
          line.startsWith('dev_dependencies:');
      continue;
    }
    final m = RegExp(r'^  ([a-z0-9_]+):\s*(\S.*?)\s*$').firstMatch(line);
    if (inDeps && m != null) out[m.group(1)!] = m.group(2)!;
  }
  return out;
}

/// Messages for packages whose constraints differ between [members]
/// (pubspec path -> contents). Workspace members (`any`) are exempt.
List<String> constraintConflicts(Map<String, String> members) {
  final seen = <String, Map<String, String>>{};
  members.forEach((path, text) {
    constraintsOf(text).forEach((name, c) {
      if (c == 'any') return;
      seen.putIfAbsent(name, () => {})[path] = c;
    });
  });
  return [
    for (final e in seen.entries)
      if (e.value.values.toSet().length > 1)
        '${e.key} has different constraints: '
            '${e.value.entries.map((x) => '${x.key} ${x.value}').join(', ')}',
  ];
}

Set<String> _dirs(String parent) => Directory(parent).existsSync()
    ? {
        for (final d in Directory(parent).listSync().whereType<Directory>())
          d.uri.pathSegments.where((s) => s.isNotEmpty).last,
      }
    : {};

/// `path:line: TODO(library: ...)` for each marker in [text]: a detail a UI
/// package could not do and was written by hand until the package gets it.
List<String> libraryGaps(String path, String text) => [
  for (final (i, line) in text.split('\n').indexed)
    if (_libraryGap.firstMatch(line) case final m?)
      '$path:${i + 1}: ${m.group(0)}',
];

void main() {
  final apps = _dirs('apps');
  final packages = _dirs('packages');
  final all = <String>[];
  final gaps = <String>[];
  for (final (parent, names) in [('apps', apps), ('packages', packages)]) {
    for (final n in names) {
      final lib = Directory('$parent/$n/lib');
      if (!lib.existsSync()) continue;
      for (final f in lib.listSync(recursive: true).whereType<File>()) {
        if (f.path.endsWith('.dart')) {
          final text = f.readAsStringSync();
          all.addAll(violations(f.path, text, apps, packages));
          gaps.addAll(libraryGaps(f.path, text));
        }
      }
    }
  }
  final pubspecs = {
    'pubspec.yaml': File('pubspec.yaml').readAsStringSync(),
    for (final n in apps)
      'apps/$n/pubspec.yaml': File('apps/$n/pubspec.yaml').readAsStringSync(),
    for (final n in packages)
      'packages/$n/pubspec.yaml': File('packages/$n/pubspec.yaml')
          .readAsStringSync(),
  };
  all.addAll(constraintConflicts(pubspecs));
  if (all.isNotEmpty) {
    stderr.writeln('Architecture violations:');
    all.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln(
    'Architecture OK (${apps.length} apps, ${packages.length} packages)',
  );
  if (gaps.isNotEmpty) {
    stdout.writeln('Open library gaps (${gaps.length}):');
    gaps.forEach(stdout.writeln);
  }
}
