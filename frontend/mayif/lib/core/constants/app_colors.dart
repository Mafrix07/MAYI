import 'package:flutter/material.dart';

class AppColors {
  // ── Fonds Nature Immersive ────────────────────────────────────────────────
  static const Color background    = Color(0xFF071A0B);  // Forêt profonde
  static const Color backgroundMid = Color(0xFF0F2D15);  // Vert mi-foncé
  static const Color backgroundCard= Color(0xFF122E17);  // Carte opaque sombre

  // ── Marque Togo ───────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF006B3F);  // Vert Togo
  static const Color primaryLight  = Color(0xFF1DB97A);  // Vert clair UI
  static const Color secondary     = Color(0xFFFFCD00);  // Or Togo
  static const Color accent        = Color(0xFFCC0001);  // Rouge Togo
  static const Color surface       = Color(0xFF0F2D15);

  // ── Textes ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);  // Blanc
  static const Color textSecondary = Color(0xB3FFFFFF);  // Blanc 70 %
  static const Color textHint      = Color(0x80FFFFFF);  // Blanc 50 %

  // ── Glassmorphism ─────────────────────────────────────────────────────────
  static const Color glassFill     = Color(0x18FFFFFF);  // Blanc 9 %
  static const Color glassFillMed  = Color(0x26FFFFFF);  // Blanc 15 %
  static const Color glassFillStrong = Color(0x33FFFFFF); // Blanc 20 %
  static const Color glassBorder   = Color(0x40FFFFFF);  // Blanc 25 %

  // ── Dégradés ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF006B3F), Color(0xFF00A86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFCD00), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF071A0B), Color(0xFF0F2D15), Color(0xFF071A0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFFCD00), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
