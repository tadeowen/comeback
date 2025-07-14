
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFF8BC34A);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBrown,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryBrown,
      secondary: lightGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 72, 112, 121),
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

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBrown,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: primaryBrown,
      secondary: lightGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 30, 60, 65),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: Colors.black,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Color(0xFF1E1E1E),
    ),
  );
}

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBrown = Color(0xFF795548);
  static const Color lightGreen = Color(0xFF8BC34A);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBrown,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryBrown,
      secondary: lightGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 72, 112, 121),
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

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBrown,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: primaryBrown,
      secondary: lightGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 30, 60, 65),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: Colors.black,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Color(0xFF1E1E1E),
    ),
  );
}

