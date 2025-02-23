import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ApiFetchModule {
  static Future<dynamic> request({
    required String url,
    Map<String, dynamic> body = const {},
    Map<String, dynamic>? queryParams, // Added queryParams

    String type = 'GET', // Changed to default to POST for sending OTP
  }) async {
    // Build the URI with query parameters if provided
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    log('uri is $uri');
    var req = http.Request(type.toUpperCase(), uri);

    Map<String, String> headers = {
      "Content-Type": "application/json", // Ensure the Content-Type is set
    };

    // Add token if required

    log('Request URL: ${uri.toString()}');
    log('Request Type: $type');
    log('Request Body: ${json.encode(body)}');

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
      // log('Response Body: $resBody');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        var data = resBody;

        return data;
      } else {
        var errorData = json.decode(resBody);
        // CustomToast.show(message: "error! something wrong", type: ToastType.error);
        throw Exception('Error: ${errorData['message'] ?? res.reasonPhrase}');
      }
    } catch (error) {
      // Provide more informative error messages
      log('Request failed: $error');
      // CustomToast.show(message: error.toString(), type: ToastType.error);
      throw Exception('Request failed: ${error.toString()}');
    }
  }
}
