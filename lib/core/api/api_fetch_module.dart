import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:watching_app_2/core/global/app_global.dart';

class ApiFetchModule {
  static Future<dynamic> request({
    required String url,
    Map<String, dynamic> body = const {},
    Map<String, dynamic>? queryParams, // Added queryParams

    String type = 'GET', // Changed to default to POST for sending OTP
  }) async {
    // Build the URI with query parameters if provided
    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    var req = http.Request(type.toUpperCase(), uri);

    Map<String, String> headers = {
      "Content-Type": "application/json", // Ensure the Content-Type is set
    };

    // Add token if required

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
      // Send the request
      var res = await req.send();
      final resBody = await res.stream.bytesToString();
      // SMA.logger.logInfo('Response statusCode: ${res.statusCode}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        var data = resBody;

        return data;
      } else {
        var errorData = json.decode(resBody);
        // CustomToast.show(message: "error! something wrong", type: ToastType.error);
        // throw Exception('Error: ${errorData['message'] ?? res.reasonPhrase}');
        SMA.logger
            .logError('Error: ${errorData['message'] ?? res.reasonPhrase}');
        return 'Error: ${errorData['message'] ?? res.reasonPhrase}';
      }
    } catch (error) {
      // Provide more informative error messages
      SMA.logger.logError('Request failed: $error');
      // CustomToast.show(message: error.toString(), type: ToastType.error);
      // throw Exception('Request failed: ${error.toString()}');
      return 'Request failed: ${error.toString()}';
    }
  }
}
