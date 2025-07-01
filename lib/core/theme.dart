import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.indigo,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.latoTextTheme().copyWith(
    headlineMedium: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyMedium: const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
    secondary: Colors.deepPurpleAccent,
  ),
);
