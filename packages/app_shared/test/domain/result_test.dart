import 'package:app_shared/domain/failure.dart';
import 'package:app_shared/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('when folds an Ok value', () {
    const Result<int> result = Ok(2);
    expect(result.when(ok: (v) => v * 2, error: (_) => -1), 4);
  });

  test('when folds an Err failure', () {
    const Result<int> result = Err(NetworkFailure('offline'));
    expect(result.when(ok: (_) => 'ok', error: (f) => f.message), 'offline');
  });
}
