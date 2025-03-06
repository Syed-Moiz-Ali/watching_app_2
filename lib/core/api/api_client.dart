import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:watching_app_2/core/global/globals.dart';

class ApiClient {
  static Future<dynamic> request({
    required String url,
    Map<String, dynamic> body = const {},
    Map<String, dynamic>? queryParams,
    String type = 'GET',
    Duration timeoutDuration =
        const Duration(seconds: 15), // Default timeout of 15 seconds
  }) async {
    // Build the URI with query parameters if provided
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    var req = http.Request(type.toUpperCase(), uri);

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    SMA.logger.logInfo(
        'Request URL: ${uri.toString()}\n Request Type: $type \n Request Body: ${json.encode(body)}');

    req.headers.addAll(headers);
    req.body = json.encode(body);

    // Connectivity check
    var connectivityResult = await Connectivity().checkConnectivity();
    while (connectivityResult.contains(ConnectivityResult.none)) {
      await Future.delayed(const Duration(seconds: 2));
      connectivityResult = await Connectivity().checkConnectivity();
    }

    try {
      // Send the request with a timeout
      var res = await req.send().timeout(
        timeoutDuration,
        onTimeout: () {
          SMA.logger.logError('Request timed out after $timeoutDuration');
          return http.StreamedResponse(
              const Stream.empty(), 408); // Simulate a timeout response
        },
      );

      final resBody = await res.stream.bytesToString();

      // Check if the response is successful
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (resBody.isEmpty) {
          SMA.logger.logInfo('Received empty response from API');
          return null; // Return null for empty response
        }
        return resBody; // Return the response body if data is present
      } else {
        var errorData = json.decode(resBody);
        SMA.logger
            .logError('Error: ${errorData['message'] ?? res.reasonPhrase}');
        return null; // Return null instead of an error string
      }
    } catch (error) {
      SMA.logger.logError('Request failed: $error');
      return null; // Return null for any exception
    }
  }
}
