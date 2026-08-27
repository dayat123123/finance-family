import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classy Luxury Stealth Dark Theme for Family Finance
class LiquidGlassTheme {
  // Deep Luxury Obsidian Backdrop
  static const Color backgroundDark = Color(0xFF090C12);
  static const Color surfaceDark = Color(0xFF101520);
  static const Color surfaceDarker = Color(0xFF0C1018);

  // Sophisticated Classy Accents (Muted, Elegant, High-End)
  static const Color primaryViolet = Color(0xFF6366F1); // Indigo Titanium
  static const Color primaryVioletLight = Color(0xFF818CF8);
  static const Color secondaryCyan = Color(0xFF38BDF8); // Sky Blue
  static const Color secondaryAqua = Color(0xFF0EA5E9);

  // Financial Semantics (Refined Luxury Shades)
  static const Color surplusEmerald = Color(0xFF10B981); // Emerald Green
  static const Color surplusEmeraldDark = Color(0xFF059669);
  static const Color defisitRose = Color(0xFFF43F5E); // Muted Rose Red
  static const Color defisitRoseLight = Color(0xFFFB7185);
  static const Color balanceAqua = Color(0xFF38BDF8);
  static const Color amberWarning = Color(0xFFF59E0B);

  // Actor / Family Palette
  static const Color actorHidayat = Color(0xFF6366F1);
  static const Color actorDeasy = Color(0xFFEC4899);

  // Glass Properties
  static const double glassBlur = 20.0;
  static const double glassBorderRadius = 24.0;

  // Classy Subtle Glass Surface
  static LinearGradient get glassSurfaceGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.015),
        ],
      );

  static LinearGradient get glassSurfaceHoverGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.03),
        ],
      );

  static LinearGradient get primaryLiquidGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF818CF8)],
      );

  static LinearGradient get surplusLiquidGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF10B981)],
      );

  static LinearGradient get defisitLiquidGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
      );

  static LinearGradient get aquaLiquidGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
      );

  // Ultra-crisp hairline specular borders
  static LinearGradient get glassBorderGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.01),
        ],
      );

  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static ThemeData get darkTheme {
    TextTheme baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryViolet,
      colorScheme: const ColorScheme.dark(
        primary: primaryViolet,
        secondary: secondaryCyan,
        surface: surfaceDark,
        error: defisitRose,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
          color: Colors.white,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Colors.white,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.1,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
