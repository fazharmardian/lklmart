import 'dart:convert';

import 'package:lks_2025/data/services/api_service.dart';

Future<void> main() async {
  final email = "ram@gmail.com".trim();
  final password = "password";

  final apiService = ApiService();

  final response = await apiService.login(email, password);

  if (response.statusCode != 200) {
    final errorData = jsonDecode(response.body);
    print("success");
    return;
  }
}
