import 'package:app_shared/domain/result.dart';

/// Port for HTTP access. Features depend on this, never on a concrete client.
abstract interface class HttpClient {
  Future<Result<Object?>> get(String path, {Map<String, Object?>? query});
}
