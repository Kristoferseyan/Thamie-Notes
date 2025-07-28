import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color _lightBackground = Color(0xFFFAFAFA);
  static const Color _lightPrimary = Color(0xFF4A90E2);
  static const Color _lightAccent = Color(0xFFF5A623);
  static const Color _lightTextPrimary = Color(0xFF333333);
  static const Color _lightTextSecondary = Color(0xFF888888);
  static const Color _lightBorder = Color(0xFFE0E0E0);
  static const Color _lightSurface = Colors.white;

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkPrimary = Color(0xFF6BA6F5);
  static const Color _darkAccent = Color(0xFFFFB84D);
  static const Color _darkTextPrimary = Color(0xFFE0E0E0);
  static const Color _darkTextSecondary = Color(0xFFB0B0B0);
  static const Color _darkBorder = Color(0xFF2A2A2A);
  static const Color _darkSurface = Color(0xFF1E1E1E);

  static bool _isDarkMode = false;

  static void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
  }

  static Color get background =>
      _isDarkMode ? _darkBackground : _lightBackground;
  static Color get primary => _isDarkMode ? _darkPrimary : _lightPrimary;
  static Color get accent => _isDarkMode ? _darkAccent : _lightAccent;
  static Color get flashcard => accent;
  static Color get textPrimary =>
      _isDarkMode ? _darkTextPrimary : _lightTextPrimary;
  static Color get textSecondary =>
      _isDarkMode ? _darkTextSecondary : _lightTextSecondary;
  static Color get subtext => textSecondary;
  static Color get border => _isDarkMode ? _darkBorder : _lightBorder;
  static Color get divider => border;
  static Color get surface => _isDarkMode ? _darkSurface : _lightSurface;

  static const Color onPrimary = Colors.white;
  static const Color onAccent = Colors.white;
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);

  static Color get primaryLight => primary.withOpacity(0.1);
  static Color get accentLight => accent.withOpacity(0.1);
  static Color get errorLight => error.withOpacity(0.1);
  static Color get successLight => success.withOpacity(0.1);
  static Color get warningLight => warning.withOpacity(0.1);

  static Color get primaryDark =>
      _isDarkMode ? const Color(0xFF5A96E8) : const Color(0xFF3A7BC8);
  static Color get accentDark =>
      _isDarkMode ? const Color(0xFFE6A532) : const Color(0xFFE09900);

  static Color get shadowLight => _isDarkMode
      ? Colors.black.withOpacity(0.2)
      : textPrimary.withOpacity(0.05);
  static Color get shadowMedium => _isDarkMode
      ? Colors.black.withOpacity(0.3)
      : textPrimary.withOpacity(0.1);
  static Color get shadowDark => _isDarkMode
      ? Colors.black.withOpacity(0.4)
      : textPrimary.withOpacity(0.15);
}
