import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // http://lks-2025.test/api
  final String baseUrl = 'http://192.168.137.1/lks-2025/public/api';
  String? _token;
  final _client = http.Client();
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Token management (from previous implementation)
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
  }

  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    _token = newToken;
  }

  // Main request method
  Future<http.Response> _request(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      // Prepare headers
      final requestHeaders = Map<String, String>.from(_defaultHeaders);
      if (headers != null) requestHeaders.addAll(headers);

      // Add auth token if required
      if (requireAuth) {
        final token = await getToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      // Prepare URI
      final uri = Uri.parse('$baseUrl/$endpoint');

      // Make the request
      switch (method.toUpperCase()) {
        case 'GET':
          return await _client.get(uri, headers: requestHeaders);
        case 'POST':
          return await _client.post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(body),
          );
        case 'PUT':
          return await _client.put(
            uri,
            headers: requestHeaders,
            body: jsonEncode(body),
          );
        case 'PATCH':
          return await _client.patch(
            uri,
            headers: requestHeaders,
            body: jsonEncode(body),
          );
        case 'DELETE':
          return await _client.delete(
            uri,
            headers: requestHeaders,
            body: jsonEncode(body),
          );
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  // Convenience methods for common HTTP verbs
  Future<http.Response> get(String endpoint,
          {Map<String, String>? headers, bool requireAuth = true}) =>
      _request('GET', endpoint, headers: headers, requireAuth: requireAuth);

  Future<http.Response> post(String endpoint,
          {dynamic body,
          Map<String, String>? headers,
          bool requireAuth = true}) =>
      _request('POST', endpoint,
          body: body, headers: headers, requireAuth: requireAuth);

  Future<http.Response> put(String endpoint,
          {dynamic body,
          Map<String, String>? headers,
          bool requireAuth = true}) =>
      _request('PUT', endpoint,
          body: body, headers: headers, requireAuth: requireAuth);

  Future<http.Response> patch(String endpoint,
          {dynamic body,
          Map<String, String>? headers,
          bool requireAuth = true}) =>
      _request('PATCH', endpoint,
          body: body, headers: headers, requireAuth: requireAuth);

  Future<http.Response> delete(String endpoint,
          {dynamic body,
          Map<String, String>? headers,
          bool requireAuth = true}) =>
      _request('DELETE', endpoint,
          body: body, headers: headers, requireAuth: requireAuth);

  // Add your specific API endpoints here
  Future<bool> validateToken() async {
    final response = await get('validate-token', requireAuth: true);

    if (response.statusCode == 200) {
      return true;
    }

    await clearToken();

    return false;
  }

  Future<http.Response> login(String email, String password) async {
    final response = await post(
      'login',
      body: {'email': email, 'password': password},
      requireAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await updateToken(data['token']);
    }

    return response;
  }

  Future<http.Response> register(String fullname, String address,
      String username, String password, String confirmPassword) async {
    final response = await post(
      'register',
      body: {
        'name': fullname,
        'address': address,
        'username': username,
        'password': password,
        'password_confirmation': confirmPassword,
      },
      requireAuth: false,
    );

    return response;
  }

  Future<http.Response> logout() async {
    final response = await post('logout', requireAuth: true);

    await clearToken();

    return response;
  }

  Future<http.Response> getItems() async {
    final response = await get('item');

    return response;
  }

  Future<http.Response> getProfile() async {
    final response = await get('profile');

    return response;
  }

  // Remember to close the client when done
  void close() {
    _client.close();
  }
}
