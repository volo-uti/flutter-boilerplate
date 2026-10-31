import 'package:dio/dio.dart';
import 'package:app_shared/data/http_dio_client.dart';
import 'package:app_shared/domain/failure.dart';
import 'package:app_shared/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  final int status;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

HttpDioClient _client(int status, String body) => HttpDioClient(
  Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeAdapter(status, body),
);

void main() {
  test('maps a 200 response to Ok', () async {
    final result = await _client(200, '{"a":1}').get('/x');
    expect(result, isA<Ok<Object?>>());
    expect((result as Ok<Object?>).value, {'a': 1});
  });

  test('maps a 500 response to ServerFailure', () async {
    final result = await _client(500, '{}').get('/x');
    final failure = (result as Err<Object?>).failure;
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 500);
  });
}
