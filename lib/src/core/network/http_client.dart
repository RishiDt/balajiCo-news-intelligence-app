// HTTP client wrapper using package:http with timeout and error translation
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mini_news_intelligence/src/config/logger.dart';
import 'package:mini_news_intelligence/src/core/constants.dart';
import 'package:mini_news_intelligence/src/core/network/network_exceptions.dart';

class HttpClient {
  final http.Client _client;
  final Duration timeout;

  HttpClient({http.Client? client, this.timeout = NETWORK_TIMEOUT})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getJson(String url,
      {Map<String, String>? headers, Map<String, String>? params}) async {
    Logger.info('network-web-client', 'getJson called. parsing uri...');
    try {
      final uri = Uri.parse(url).replace(queryParameters: {
        if (params != null) ...params,
      });
      final mergedHeaders = {
        'Accept': 'application/json',
        if (API_KEY.isNotEmpty) 'X-Api-Key': API_KEY,
        if (headers != null) ...headers,
      };
      final response =
          await _client.get(uri, headers: mergedHeaders).timeout(timeout);
      Logger.info('network-web-client', response.body);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on Exception catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final mergedHeaders = {
        'Content-Type': 'application/json',
        if (API_KEY.isNotEmpty) 'X-Api-Key': API_KEY,
        if (headers != null) ...headers,
      };
      final response = await _client
          .post(uri, headers: mergedHeaders, body: jsonEncode(body))
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on Exception catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json;
      } catch (e) {
        throw ParsingException('Invalid JSON: ${e.toString()}');
      }
    } else {
      String message = response.body;
      try {
        final json = jsonDecode(response.body);
        if (json is Map && json['message'] != null) {
          message = json['message'].toString();
        }
      } catch (_) {}
      throw ApiException('HTTP $status: $message', code: status);
    }
  }

  void close() => _client.close();
}
