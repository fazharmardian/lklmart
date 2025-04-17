import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/services/api_service.dart';
import '../widgets/snackbar.dart';
import '../widgets/textformfield.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isObscure = true;
  bool isConfirmObscure = true;
  bool isLoading = false;

  // Controllers for form fields
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _fullnameController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.register(
        _fullnameController.text,
        _addressController.text,
        _usernameController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200) {
        CustomSnackBar.showError(
          context: context,
          message: responseData['message']?.toString() ?? 'Registration failed',
        );
        return;
      }

      CustomSnackBar.showSuccess(
        context: context,
        message: responseData['message'] ?? 'Registration successful!',
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Registration failed: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey, // Assign the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Sign Up',
                    style: GoogleFonts.inter(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Silahkan isi Data Pribadi Anda',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Full Name Field
                CustomTextFormField(
                  controller: _fullnameController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Nama Lengkap',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your fullname';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),

                // Address Field
                CustomTextFormField(
                  controller: _addressController,
                  labelText: 'Alamat',
                  hintText: 'Alamat',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),

                // Username Field
                CustomTextFormField(
                  controller: _usernameController,
                  labelText: 'Username',
                  hintText: 'username',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),

                // Password Field
                CustomTextFormField(
                  controller: _passwordController,
                  labelText: 'Password*',
                  hintText: 'Min. 8 characters',
                  obscureText: isObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    child: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Confirm Password Field
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Password*',
                  hintText: 'Min. 8 characters',
                  obscureText: isConfirmObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isConfirmObscure = !isConfirmObscure;
                      });
                    },
                    child: Icon(
                      isConfirmObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    backgroundColor: const Color(0xFF315472),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : _register,
                  child: Text('Daftar',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(height: 16),

                // Register Link
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Sudah punya akun? ',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login di sini',
                          style: GoogleFonts.inter(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to Register Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
