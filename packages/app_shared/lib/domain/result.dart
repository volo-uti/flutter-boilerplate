import 'package:app_shared/domain/failure.dart';

/// Outcome of an operation that can fail in an expected way.
sealed class Result<T> {
  const Result();

  /// Folds both outcomes into a single value.
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) error,
  }) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Err<T>(:final failure) => error(failure),
  };
}

/// Successful [Result] carrying [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Failed [Result] carrying the expected [failure].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
