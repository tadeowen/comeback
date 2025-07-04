import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFF8BC34A);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryBrown,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryBrown,
      secondary: lightGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBrown,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
