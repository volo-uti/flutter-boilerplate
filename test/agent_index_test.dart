// Imports the script by relative path: scripts/ is outside any lib/.
import 'package:flutter_test/flutter_test.dart';

import '../scripts/agent_index.dart';

void main() {
  test('indexes public declarations with the first doc sentence', () {
    const source = '''
import 'package:flutter/material.dart';

/// Does a thing. More detail
/// on a second line.
@immutable
class Thing {}

class _Hidden {}

/// Builds the answer.
int answer() => 42;

final Undocumented = 1;
''';
    final decls = declarations(source);
    expect(decls.map((d) => d.name), ['Thing', 'answer', 'Undocumented']);
    expect(decls[0].doc, 'Does a thing.');
    expect(decls[1].doc, 'Builds the answer.');
    expect(decls[2].doc, isEmpty);
    expect(decls[2].line, 13);
  });

  test('indexLine joins names in source order', () {
    expect(
      indexLine('package:p/a.dart', const [
        Decl('A', 1, 'One.'),
        Decl('B', 2, 'Two.'),
      ]),
      'package:p/a.dart|A: One. B: Two.',
    );
  });

  test('indexLine merges consecutive names sharing a sentence', () {
    expect(
      indexLine('p|', const [Decl('A', 1, 'Same.'), Decl('B', 2, 'Same.')]),
      'p||A, B: Same.',
    );
  });

  test('applyBlock replaces the managed block and is idempotent', () {
    final once = applyBlock('# T\n\n## Rules\n- x\n', renderBlock(['a|A: 1.']));
    final twice = applyBlock(once, renderBlock(['a|A: 1.']));
    expect(twice, once);
    expect(currentBlock(once), contains('a|A: 1.'));
    expect(once.indexOf(beginMarker), lessThan(once.indexOf('## Rules')));
  });
}
