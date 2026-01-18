import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShadcnTheme {
  // ===================== CORE PALETTE =====================
  static const Color background = Color(0xFFF8FAFB);
  static const Color foreground = Color(0xFF1E293B);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1E293B);
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF1E293B);
  static const Color primary = Color(0xFF0F4C81);
  static const Color primaryForeground = Colors.white;
  static const Color secondary = Color(0xFF4FD1C5);
  static const Color secondaryForeground = Color(0xFF0F4C81);
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color accent = Color(0xFF6EE7B7);
  static const Color accentForeground = Color(0xFF064E3B);
  static const Color destructive = Color(0xFF991B1B);
  static const Color destructiveForeground = Colors.white;
  static const Color border = Color(0x1A0F4C81);
  static const Color input = Color(0x1A0F4C81);
  static const Color ring = Color(0xFF4FD1C5);

  static const double radiusDefault = 16.0;
  static const double radiusSm = 8.0;
  static const double radiusLg = 24.0;

  // ===================== TYPOGRAPHY =====================
  static TextStyle get textStyle => GoogleFonts.inter(color: foreground, fontSize: 14);
  static TextStyle get h1 => GoogleFonts.inter(color: foreground, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static TextStyle get h2 => GoogleFonts.inter(color: foreground, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5);
  static TextStyle get h3 => GoogleFonts.inter(color: foreground, fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get h4 => GoogleFonts.inter(color: foreground, fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get small => GoogleFonts.inter(color: mutedForeground, fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle get lead => GoogleFonts.inter(color: mutedForeground, fontSize: 16, fontWeight: FontWeight.w400);

  // ===================== UTILS =====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [secondary, Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED': return const Color(0xFF10B981);
      case 'IN-PROGRESS': return const Color(0xFFF59E0B);
      case 'SUBMITTED': return const Color(0xFF0F4C81);
      default: return mutedForeground;
    }
  }

  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: card,
        onSurface: cardForeground,
        onPrimary: primaryForeground,
        onSecondary: secondaryForeground,
        error: destructive,
        onError: destructiveForeground,
        outline: border,
      ),
    );
  }
}