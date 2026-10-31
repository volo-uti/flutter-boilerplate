/// Expected failure categories. Handle them with an exhaustive `switch`.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// The network or server could not be reached.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// The server answered with a non-success status.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {required this.statusCode});

  final int statusCode;
}

/// Anything that does not fit the other categories.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
