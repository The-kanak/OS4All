import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'api_exception.dart';
import '../storage/token_storage.dart';

/// Centralized, production-grade HTTP/REST API client for OS4All.
/// Handles base URL routing, JWT Bearer tokens, JSON serialization,
/// multipart PDF report upload, timeouts, and structured error unwrapping.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _httpClient = http.Client();
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Duration _uploadTimeout = Duration(seconds: 45);

  /// Builds standard request headers with JWT Bearer authentication when available.
  Future<Map<String, String>> _buildHeaders({bool isJson = true, String? customToken}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    final token = customToken ?? await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Resolves target Uri from endpoint path and optional query parameters.
  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final baseUrl = AppConfig.apiBaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$baseUrl$cleanPath';

    if (queryParameters == null || queryParameters.isEmpty) {
      return Uri.parse(fullUrl);
    }

    final stringParams = queryParameters.map((key, value) => MapEntry(key, value.toString()));
    final baseUri = Uri.parse(fullUrl);
    return baseUri.replace(queryParameters: {
      ...baseUri.queryParameters,
      ...stringParams,
    });
  }

  /// Processes HTTP responses, unwrapping the standard OS4All ApiResponse envelope.
  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body);
      }
    } catch (_) {
      // Body is not JSON
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        // Unpack standard ApiResponse { success: true, message: "...", data: ... }
        if (body.containsKey('data')) {
          return body['data'];
        }
        return body;
      }
      return body;
    }

    // Extract error message
    String errorMessage = 'Server returned HTTP ${response.statusCode}';
    if (body is Map<String, dynamic>) {
      if (body['message'] != null && body['message'].toString().isNotEmpty) {
        errorMessage = body['message'].toString();
      } else if (body['error'] != null && body['error'].toString().isNotEmpty) {
        errorMessage = body['error'].toString();
      }
    }

    if (response.statusCode == 401) {
      throw ApiException(
        'Authentication required. Please sign in to access your health data.',
        statusCode: 401,
        details: body,
      );
    }

    if (response.statusCode == 403) {
      throw ApiException(
        errorMessage.contains('consent')
            ? errorMessage
            : 'Access restricted. Please verify health permissions in settings.',
        statusCode: 403,
        details: body,
      );
    }

    if (response.statusCode == 404) {
      throw ApiException(
        errorMessage.isNotEmpty ? errorMessage : 'The requested health record was not found.',
        statusCode: 404,
        details: body,
      );
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      details: body,
    );
  }

  /// Executes an HTTP GET request.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, String? customToken}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final headers = await _buildHeaders(customToken: customToken);
      final response = await _httpClient.get(uri, headers: headers).timeout(_defaultTimeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  /// Executes an HTTP POST request.
  Future<dynamic> post(String path, {dynamic body, Map<String, dynamic>? queryParameters, String? customToken}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final headers = await _buildHeaders(customToken: customToken);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient.post(uri, headers: headers, body: encodedBody).timeout(_defaultTimeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  /// Executes an HTTP PUT request.
  Future<dynamic> put(String path, {dynamic body, Map<String, dynamic>? queryParameters, String? customToken}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final headers = await _buildHeaders(customToken: customToken);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient.put(uri, headers: headers, body: encodedBody).timeout(_defaultTimeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  /// Executes an HTTP DELETE request.
  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters, String? customToken}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final headers = await _buildHeaders(customToken: customToken);
      final response = await _httpClient.delete(uri, headers: headers).timeout(_defaultTimeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  /// Uploads a medical lab report file (PDF/Image) using multipart/form-data.
  Future<dynamic> uploadReport({
    required List<int> fileBytes,
    required String filename,
    String? title,
    String? customToken,
  }) async {
    try {
      final uri = _buildUri('/reports/upload');
      final request = http.MultipartRequest('POST', uri);

      final token = customToken ?? await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      if (title != null && title.trim().isNotEmpty) {
        request.fields['title'] = title.trim();
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _wrapNetworkError(e);
    }
  }

  ApiException _wrapNetworkError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('connection refused') || msg.contains('failed host lookup') || msg.contains('socketexception')) {
      return ApiException(
        'Unable to connect to OS4All server (${AppConfig.apiBaseUrl}). Please verify the backend is running.',
        statusCode: 0,
        details: e,
      );
    }
    if (msg.contains('timeoutexception')) {
      return ApiException(
        'Network request timed out. Please check your network and try again.',
        statusCode: 408,
        details: e,
      );
    }
    return ApiException(
      'Network communication error: ${e.toString()}',
      statusCode: 0,
      details: e,
    );
  }
}
