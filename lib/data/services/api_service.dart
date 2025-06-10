import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _baseUrl = 'https://lkmart.vercel.app/public/api';
  final _client = http.Client();
  String? _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token!',
      };

  Future<void> _loadToken() async {
    _token ??= (await SharedPreferences.getInstance()).getString('token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    (await SharedPreferences.getInstance()).setString('token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
  }

  Future<http.Response> _request(String method, String endpoint,
      {dynamic body, bool auth = true}) async {
    if (auth) await _loadToken();
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final h = _headers;

    switch (method) {
      case 'GET':
        return _client.get(uri, headers: h);
      case 'POST':
        return _client.post(uri, headers: h, body: jsonEncode(body));
      case 'PUT':
        return _client.put(uri, headers: h, body: jsonEncode(body));
      case 'PATCH':
        return _client.patch(uri, headers: h, body: jsonEncode(body));
      case 'DELETE':
        return _client.delete(uri, headers: h, body: jsonEncode(body));
      default:
        throw Exception('Invalid method');
    }
  }

  // Common requests
  Future<http.Response> get(String e, {bool auth = true}) =>
      _request('GET', e, auth: auth);
  Future<http.Response> post(String e, dynamic b, {bool auth = true}) =>
      _request('POST', e, body: b, auth: auth);

  // Auth & user
  Future<http.Response> login(String email, String password) async {
    final res = await post('login', {'email': email, 'password': password}, auth: false);
    if (res.statusCode == 200) await _saveToken(jsonDecode(res.body)['token']);
    return res;
  }

  Future<http.Response> register(String name, String address, String user,
          String pass, String confirmPass) =>
      post('register', {
        'name': name,
        'address': address,
        'username': user,
        'password': pass,
        'password_confirmation': confirmPass,
      }, auth: false);

  Future<http.Response> logout() async {
    final res = await post('logout', {}, auth: true);
    await clearToken();
    return res;
  }

  // App-specific
  Future<bool> validateToken() async {
    final res = await get('validate-token');
    if (res.statusCode != 200) await clearToken();
    return res.statusCode == 200;
  }

  Future<http.Response> getItems() => get('item');
  Future<http.Response> getProfile() => get('profile');

  void close() => _client.close();
}
