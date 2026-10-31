import 'package:dio/dio.dart';
import 'package:app_shared/data/http_client.dart';
import 'package:app_shared/domain/failure.dart';
import 'package:app_shared/domain/result.dart';

/// [HttpClient] backed by dio. Maps transport errors to [Failure]s.
class HttpDioClient implements HttpClient {
  HttpDioClient(this._dio);

  final Dio _dio;

  @override
  Future<Result<Object?>> get(
    String path, {
    Map<String, Object?>? query,
  }) async {
    try {
      final response = await _dio.get<Object?>(path, queryParameters: query);
      return Ok(response.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null) {
        return Err(
          ServerFailure(e.message ?? 'HTTP $status', statusCode: status),
        );
      }
      return Err(NetworkFailure(e.message ?? 'Network error'));
    } on Object catch (e) {
      return Err(UnknownFailure('$e'));
    }
  }
}
