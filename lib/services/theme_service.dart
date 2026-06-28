import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeData get currentTheme =>
      _isDark ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // ── Dark Theme ──────────────────────────────
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00BFA5),
      secondary: Color(0xFFE91E8C),
      surface: Color(0xFF1A1F2E),
    ),
    cardColor: const Color(0xFF1A1F2E),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white38),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00BFA5)),
      ),
      labelStyle: TextStyle(color: Colors.white54),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white54),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
          color: Color(0xFF00BFA5), fontSize: 16),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  // ── Light Theme ──────────────────────────────
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00897B),
      secondary: Color(0xFFE91E8C),
      surface: Color(0xFFFFFFFF),
    ),
    cardColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black38),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00897B)),
      ),
      labelStyle: TextStyle(color: Colors.black54),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    iconTheme: const IconThemeData(color: Colors.black54),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
          color: Color(0xFF00897B), fontSize: 16),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}