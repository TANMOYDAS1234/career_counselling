import 'package:dio/dio.dart';

/// User-friendly wrapper around network/server failures.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;

  /// Maps a [DioException] to a human-readable message.
  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('The request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const ApiException(
          'Cannot reach the server. Check your connection and that the backend is running.',
        );
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          return ApiException(data['message'] as String);
        }
        return ApiException('Server error (${e.response?.statusCode ?? '?'}).');
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }
}
