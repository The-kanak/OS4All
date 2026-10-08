import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BodyOS Clean Modern White & Blue Health Identity for OS4All
/// Crisp Off-White Foundation (#F8FAFC) + Pure White Cards (#FFFFFF)
/// Vibrant Royal/Medical Blue (#1E60FF) + Sky Blue (#0EA5E9) + Medical Emerald (#10B981)
class AppTheme {
  // BodyOS Clean Modern White & Blue Health Identity
  static const Color background = Color(0xFFF8FAFC);       // Crisp Off-White
  static const Color surface = Color(0xFFFFFFFF);          // Pure White
  static const Color surfaceElevated = Color(0xFFF1F5F9);  // Soft Cool Slate
  static const Color surfaceLight = Color(0xFFF1F5F9);     // Soft Cool Slate alias
  static const Color border = Color(0xFFE2E8F0);           // Clean Slate Border
  static const Color borderLight = Color(0xFFCBD5E1);      // Subtle Border
  static const Color cardBg = Color(0xFFFFFFFF);           // White card surface
  static const Color cardBorder = Color(0xFFE2E8F0);       // Clean slate border

  // Accents & Telemetry States
  static const Color primary = Color(0xFF0D9488);          // OS4All Calming Medical Teal
  static const Color secondary = Color(0xFF6366F1);        // Complementary Indigo
  static const Color stable = Color(0xFF10B981);           // Medical Emerald Green (Normal)
  static const Color attention = Color(0xFFF59E0B);        // Warm Amber
  static const Color critical = Color(0xFFEF4444);         // Coral Crimson (Alert)
  static const Color success = Color(0xFF10B981);          // Green
  static const Color warning = Color(0xFFF59E0B);          // Amber
  static const Color danger = Color(0xFFEF4444);           // Red
  static const Color info = Color(0xFF0D9488);             // Teal

  // Typography Tokens
  static const Color textPrimary = Color(0xFF0F172A);      // Deep Slate Charcoal
  static const Color textSecondary = Color(0xFF475569);    // Slate Grey
  static const Color textMuted = Color(0xFF94A3B8);        // Muted Slate

  // Compatibility Aliases for OS4All Widgets
  static const Color cyan = primary;                       // Mapped to BodyOS Royal Blue
  static const Color cyanMuted = secondary;                // Sky Blue
  static const Color indigo = primary;                     // Royal Blue
  static const Color violet = secondary;
  static const Color primaryCyan = primary;
  static const Color cyanAccent = secondary;
  static const Color medicalTeal = primary;
  static const Color vitalityGreen = stable;
  static const Color warningAmber = warning;
  static const Color criticalCoral = critical;
  static const Color accentIndigo = Color(0xFF1E60FF);
  static const Color accentPurple = Color(0xFF0EA5E9);
  static const Color electricBlue = primary;
  static const Color primaryBackground = background;
  static const Color surfaceCard = surface;
  static const Color surfaceCardLight = surfaceElevated;
  static const Color surfaceCardElevated = surfaceElevated;
  static const Color surfaceBorder = border;
  static const Color surfaceBorderLight = borderLight;
  static const Color surfaceMuted = surfaceElevated;
  static const Color textLight = textSecondary;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E60FF), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stableGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vitalityGradient = stableGradient;

  static const LinearGradient attentionGradient = LinearGradient(
    colors: [Color(0xFF1E60FF), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = attentionGradient;

  static const LinearGradient criticalGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alertGradient = criticalGradient;

  static const LinearGradient geminiGradient = LinearGradient(
    colors: [Color(0xFF1E60FF), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F6FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = cardGlassGradient;

  // Box Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 14,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.18),
      blurRadius: 18,
      spreadRadius: 1,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 22,
      offset: const Offset(0, 6),
    ),
  ];

  // Theme definition - BodyOS Clean Light Theme
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: critical,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: critical),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.14),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: primary);
          }
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
      ),
    );
  }

  // Alias darkTheme to lightTheme for consistent BodyOS white & blue aesthetic
  static ThemeData get darkTheme => lightTheme;
}
