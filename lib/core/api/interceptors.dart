import 'package:http/http.dart' as http;
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/core/network/exceptions.dart';

abstract class Interceptor {
  Future<http.Request> onRequest(http.Request request);
  Future<http.StreamedResponse> onResponse(http.StreamedResponse response);
  Future<void> onError(Object error);
}

class LoggingInterceptor implements Interceptor {
  @override
  Future<http.Request> onRequest(http.Request request) async {
    SMA.logger.logInfo(
        'Request: ${request.method} ${request.url}\nBody: ${request.body}');
    return request;
  }

  @override
  Future<http.StreamedResponse> onResponse(
      http.StreamedResponse response) async {
    SMA.logger
        .logInfo('Response: ${response.statusCode} ${response.reasonPhrase}');
    return response;
  }

  @override
  Future<void> onError(Object error) async {
    SMA.logger.logError('API Error: $error');
  }
}

class AuthInterceptor implements Interceptor {
  @override
  Future<http.Request> onRequest(http.Request request) async {
    // Add auth token if available
    // if (SMA.authToken != null) {
    //   request.headers['Authorization'] = 'Bearer ${SMA.authToken}';
    // }
    return request;
  }

  @override
  Future<http.StreamedResponse> onResponse(
      http.StreamedResponse response) async {
    if (response.statusCode == 401) {
      // Handle token refresh logic here
      SMA.logger.logWarning('Unauthorized request, attempting token refresh');
      // Example: await refreshToken();
    }
    return response;
  }

  @override
  Future<void> onError(Object error) async {
    SMA.logger.logError('Auth error: $error');
  }
}

class RetryInterceptor implements Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({required this.maxRetries, required this.retryDelay});

  @override
  Future<http.Request> onRequest(http.Request request) async => request;

  @override
  Future<http.StreamedResponse> onResponse(
          http.StreamedResponse response) async =>
      response;

  @override
  Future<void> onError(Object error) async {
    if (error is ApiException && error.statusCode >= 500) {
      SMA.logger.logWarning('Retrying request due to server error: $error');
    }
  }
}
