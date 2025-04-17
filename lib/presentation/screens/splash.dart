import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/api_service.dart';
import 'login.dart';
import 'main_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
  // First ensure minimum splash duration
  await Future.delayed(const Duration(seconds: 1));

  // Validate token
  final apiService = ApiService();
  final isValidToken = await apiService.validateToken(); 
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isValidToken && token != null 
            ? MainHomeScreen() 
            : LoginScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "LKS MART",
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF315472),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
