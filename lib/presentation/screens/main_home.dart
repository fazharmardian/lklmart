import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'product.dart';
import 'profile.dart';

// main_home_screen.dart
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  // Screens to display for each tab
  final List<Widget> _screens = [
    const ProductScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavItem(0, Icons.dashboard, 'Produk'),
            const SizedBox(width: 50),
            _buildNavItem(1, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: _currentIndex == index ? Color(0xFF315472) : Colors.grey,
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _currentIndex == index ? Color(0xFF315472) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
