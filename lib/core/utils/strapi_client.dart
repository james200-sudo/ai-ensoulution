import 'dart:convert';
import 'package:http/http.dart' as http;


class StrapiClient {
  final String apiUrl;
  String? _jwt;

  StrapiClient({required this.apiUrl});

  void setJwt(String jwt) {
    _jwt = jwt;
  }

  void clearJwt() {
    _jwt = null;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_jwt != null) {
      headers['Authorization'] = 'Bearer $_jwt';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Future.value(body);
    } else {
      throw StrapiException(body['error']?['message'] ?? 'An error occurred',
          response.statusCode);
    }
  }

  // Generate device fingerprint (simplified version)
  Map<String, dynamic> _getUserFingerprint() {
    return <String, dynamic>{'1': 1};
  }

  // Authentication
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/local/register'),
      headers: _headers,
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final loginPayload = {
      'identifier': identifier.trim(),
      'password': password.trim(),
      ..._getUserFingerprint(),
    };

    final response = await http.post(
      Uri.parse('$apiUrl/auth/local'),
      headers: _headers,
      body: json.encode(loginPayload),
    );
    final data = await _handleResponse(response);
    if (data['jwt'] != null) {
      setJwt(data['jwt']);
    }
    return data;
  }

  // CRUD Operations
  Future<Map<String, dynamic>> find(String contentType,
      {Map<String, dynamic>? params}) async {
    final uri =
        Uri.parse('$apiUrl/$contentType').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> findOne(String contentType, int id,
      {Map<String, dynamic>? params}) async {
    final uri = Uri.parse('$apiUrl/$contentType/$id')
        .replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> create(
      String contentType, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$contentType'),
      headers: _headers,
      body: json.encode({'data': data}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> update(
      String contentType, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$contentType/$id'),
      headers: _headers,
      body: json.encode({'data': data}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String contentType, int id) async {
    final response = await http
        .delete(Uri.parse('$apiUrl/$contentType/$id'), headers: _headers);
    return _handleResponse(response);
  }
}

class StrapiException implements Exception {
  final String message;
  final int statusCode;

  StrapiException(this.message, this.statusCode);

  @override
  String toString() {
    return 'StrapiException: $message (Status code: $statusCode)';
  }
}