import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Curated Dark Palette
  static const Color darkBg = Color(0xFF0F0C1B); // Deep space purple
  static const Color darkSurface = Color(0xFF16122C); // Dark violet surface
  static const Color darkPrimary = Color(0xFF6366F1); // Indigo
  static const Color darkSecondary = Color(0xFF06B6D4); // Cyan
  static const Color darkAccent = Color(0xFFD946EF); // Fuchsia
  static const Color darkTextPrimary = Color(0xFFF3F4F6); // Soft white
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Soft gray
  static const Color darkBorder = Color(0xFF2E2A4F); // Muted border

  // Curated Light Palette
  static const Color lightBg = Color(0xFFF9FAFB); // Soft light gray
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightPrimary = Color(0xFF4F46E5); // Indigo
  static const Color lightSecondary = Color(0xFF0891B2); // Cyan
  static const Color lightAccent = Color(0xFFC084FC); // Soft purple
  static const Color lightTextPrimary = Color(0xFF111827); // Dark gray/black
  static const Color lightTextSecondary = Color(0xFF4B5563); // Muted gray
  static const Color lightBorder = Color(0xFFE5E7EB); // Soft gray border

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: lightBg,
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        bodyLarge: const TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: lightTextSecondary, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        error: Color(0xFFF87171),
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        bodyLarge: const TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
      ),
    );
  }
}
