import 'package:app_shared/data/http_client.dart';
import 'package:app_shared/domain/result.dart';

/// In-memory [HttpClient] used by default so the app runs without a backend.
class MockHttpClient implements HttpClient {
  const MockHttpClient([this.responses = const {}]);

  /// Canned response bodies keyed by request path.
  final Map<String, Object?> responses;

  @override
  Future<Result<Object?>> get(
    String path, {
    Map<String, Object?>? query,
  }) async => Ok(responses[path]);
}
