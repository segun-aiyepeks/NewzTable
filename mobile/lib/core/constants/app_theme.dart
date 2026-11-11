import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Primary brand colors inspired by the modern Kabar UI
  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color darkBackground = Color(0xFF18191A);
  static const Color darkSurface = Color(0xFF1F222A);
  static const Color darkSurfaceElevated = Color(0xFF262A34);
  static const Color darkBorder = Color(0xFF2E333D);
  static const Color textMuted = Color(0xFF9EA3AE);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get darkTheme => _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF1E3A5F),
        onPrimaryContainer: Color(0xFF90CAF9),
        secondary: Color(0xFF3B82F6),
        surface: darkSurface,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: darkSurfaceElevated,
        outline: darkBorder,
        outlineVariant: Color(0xFF3E4351),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: textPrimaryDark),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: textPrimaryDark),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: textPrimaryDark),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: textPrimaryDark),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: textPrimaryDark),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: textPrimaryDark),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: textPrimaryDark),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimaryDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFFE4E6EB)),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textMuted),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 0.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Color(0xFF6C757D),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBackground,
        indicatorColor: primaryBlue.withAlpha(40),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryBlue, fontWeight: FontWeight.w700, fontSize: 11);
          }
          return const TextStyle(color: Color(0xFF8E93A0), fontWeight: FontWeight.w500, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue, size: 24);
          }
          return const IconThemeData(color: Color(0xFF8E93A0), size: 24);
        }),
      ),
      dividerColor: darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: Color(0xFF7A808C), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData _buildLightTheme() {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);
    const lightSurface = Color(0xFFF8F9FA);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE7F0FF),
        onPrimaryContainer: primaryBlue,
        secondary: Color(0xFF0D6EFD),
        surface: lightSurface,
        onSurface: Color(0xFF1A1D20),
        surfaceContainerHighest: Color(0xFFEEF0F4),
        outline: Color(0xFFE2E4E9),
        outlineVariant: Color(0xFFD0D5DD),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D20)),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D20)),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1D20)),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1D20)),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1D20)),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A1D20)),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A1D20)),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: const Color(0xFF2B2F36)),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5363)),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF1A1D20)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1D20),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E4E9), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryBlue.withAlpha(25),
        elevation: 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryBlue, fontWeight: FontWeight.w700, fontSize: 11);
          }
          return const TextStyle(color: Color(0xFF717886), fontWeight: FontWeight.w500, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue, size: 24);
          }
          return const IconThemeData(color: Color(0xFF717886), size: 24);
        }),
      ),
      dividerColor: const Color(0xFFE2E4E9),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: const TextStyle(color: Color(0xFF9AA1B0), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E4E9), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E4E9), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
