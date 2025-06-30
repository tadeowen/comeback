import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  textTheme: GoogleFonts.latoTextTheme(),
);

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.indigo,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    headline4: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyText2: TextStyle(
      fontSize: 16,
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
