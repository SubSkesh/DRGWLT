import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor:  const Color(0xFF121212),//colore background scaffold
      // primaryColor: const Color(0xFFE3B873), // non lousiamo dato che lo definiamo sotto
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE3B873),
        secondary: Color(0xFF1F1F1F),
        surface: Color(0xFF1F1F1F),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE3B873),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFE3B873),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,//Attiva il colore di sfondo nel campo di input.

        fillColor: Color(0xFF1F1F1F),// colore di sfondo nel campo di input
        labelStyle: TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE3B873)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE3B873), width: 2),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        selectedItemColor: Color(0xFFE3B873),
        unselectedItemColor: Colors.white60,)

    );
  }
}
