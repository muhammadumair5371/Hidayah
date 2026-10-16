import 'package:flutter/material.dart';

class AppTheme {
  // Dark Green Islamic Theme Palette
  static const Color primaryGreen = Color(0xFF0F291E);
  static const Color secondaryGreen = Color(0xFF1B4D3E);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF3E5AB);
  static const Color backgroundDark = Color(0xFF07140E);
  static const Color surfaceDark = Color(0xFF132E22);
  static const Color surfaceCard = Color(0xFF1A3D2E);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFFA3B8AE);
  static const Color errorRed = Color(0xFFCF6679);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: secondaryGreen,
        secondary: accentGold,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: textLight,
        onSecondary: primaryGreen,
        onSurface: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: accentGold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textLight, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textLight, fontSize: 26, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textLight, fontSize: 15),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14),
        labelLarge: TextStyle(color: accentGold, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
