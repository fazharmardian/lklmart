import 'package:flutter/material.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class CustomSnackBar {
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showAnimatedSnackBar(
      context: context,
      message: message,
      type: AnimatedSnackBarType.success,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showAnimatedSnackBar(
      context: context,
      message: message,
      type: AnimatedSnackBarType.error,
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showAnimatedSnackBar(
      context: context,
      message: message,
      type: AnimatedSnackBarType.info,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showAnimatedSnackBar(
      context: context,
      message: message,
      type: AnimatedSnackBarType.warning,
      duration: duration,
    );
  }

  static void _showAnimatedSnackBar({
    required BuildContext context,
    required String message,
    required AnimatedSnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    AnimatedSnackBar.material(
      message,
      type: type,
      duration: duration,
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 50,
        bottomOnAppearance: 100,
      ),
    ).show(context);
  }
}