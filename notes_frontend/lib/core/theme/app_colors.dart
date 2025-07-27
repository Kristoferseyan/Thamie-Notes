import 'package:flutter/material.dart';

/// App Colors
///
/// A centralized place for all color definitions used throughout the app.
/// This makes it easy to maintain consistency and update colors globally.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Background Colors
  static const Color background = Color(
    0xFFFAFAFA,
  ); // Soft white - Minimal, paper-like

  // Primary Colors
  static const Color primary = Color(
    0xFF4A90E2,
  ); // Calm blue - Headers, buttons

  // Accent Colors
  static const Color accent = Color(
    0xFFF5A623,
  ); // Warm amber - Flashcard highlights/quiz mode
  static const Color flashcard = accent; // Alias for clarity

  // Text Colors
  static const Color textPrimary = Color(
    0xFF333333,
  ); // Near black - High readability
  static const Color textSecondary = Color(
    0xFF888888,
  ); // Gray - Timestamps, secondary text
  static const Color subtext = textSecondary; // Alias for clarity

  // Border and Divider Colors
  static const Color border = Color(
    0xFFE0E0E0,
  ); // Light gray - For separating note sections
  static const Color divider = border; // Alias for clarity

  // Additional useful colors derived from the main palette
  static const Color surface =
      Colors.white; // Pure white for cards and surfaces
  static const Color onPrimary = Colors.white; // Text on primary background
  static const Color onAccent = Colors.white; // Text on accent background
  static const Color error = Color(0xFFE53E3E); // Error states
  static const Color success = Color(0xFF38A169); // Success states
  static const Color warning = Color(0xFFD69E2E); // Warning states

  // Light variants for subtle backgrounds
  static Color primaryLight = primary.withOpacity(0.1);
  static Color accentLight = accent.withOpacity(0.1);
  static Color errorLight = error.withOpacity(0.1);
  static Color successLight = success.withOpacity(0.1);
  static Color warningLight = warning.withOpacity(0.1);

  // Darker variants for hover states
  static Color primaryDark = const Color(0xFF3A7BC8);
  static Color accentDark = const Color(0xFFE09900);

  // Shadow colors
  static Color shadowLight = textPrimary.withOpacity(0.05);
  static Color shadowMedium = textPrimary.withOpacity(0.1);
  static Color shadowDark = textPrimary.withOpacity(0.15);
}
