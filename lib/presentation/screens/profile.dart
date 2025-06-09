import 'dart:convert';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../data/models/user.dart';
import '../../data/services/api_service.dart';
import 'splash.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool profileLoading = false;
  User? user;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    setState(() {
      isLoading = true;
      profileLoading = true;
      errorMessage = '';
    });

    try {
      final apiService = ApiService();
      final response = await apiService.getProfile();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        setState(() {
          user = User.fromJson(responseData['user'] ?? responseData);
        });
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ??
            errorResponse['error'] ??
            'Failed to load profile (HTTP ${response.statusCode})');
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
      _showError(errorMessage);
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          profileLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() => isLoading = true);
    try {
      final apiService = ApiService();
      final response = await apiService.logout();

      if (!mounted) return;

      if (response.statusCode != 200) {
        throw Exception('Logout failed (HTTP ${response.statusCode})');
      }

      AnimatedSnackBar.material(
        'Logout successful',
        type: AnimatedSnackBarType.success,
      ).show(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      if (mounted) {
        AnimatedSnackBar.material(
          e.toString(),
          type: AnimatedSnackBarType.error,
        ).show(context);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      AnimatedSnackBar.material(
        message,
        type: AnimatedSnackBarType.error,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 24),
            child: Row(
              children: [
                Text(
                  "Profile",
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF315472),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withValues(alpha: 0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.person, size: 80, color: Color(0xFF315472)),
                profileLoading
                    ? Center(
                        child: Text(
                          'Loading..',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF315472),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileLoading ? '' : user?.name ?? 'No username',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF315472),
                            ),
                          ),
                          Text(
                            profileLoading
                                ? ''
                                : user?.phone ?? 'No phone number',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            profileLoading ? '' : user?.address ?? 'No address',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 42),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isLoading ? null : _logout,
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
