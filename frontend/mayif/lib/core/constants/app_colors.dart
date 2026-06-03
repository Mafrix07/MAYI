import 'package:flutter/material.dart';

class AppColors {
  // ── Fonds Nuit Plage ──────────────────────────────────────────────────────
  static const Color background     = Color(0xFF0A0D0B);  // Quasi-noir, légère teinte forêt
  static const Color backgroundMid  = Color(0xFF0F1610);  // Un cran plus clair
  static const Color backgroundCard = Color(0xFF141D15);  // Carte opaque sombre

  // ── Palette Mayi — tirée directement du logo ──────────────────────────────
  static const Color primary        = Color(0xFF1A5C2E);  // Vert palmier profond
  static const Color primaryLight   = Color(0xFF2EA855);  // Vert clair UI
  static const Color secondary      = Color(0xFFE8821A);  // Orange soleil (logo)
  static const Color ocean          = Color(0xFF0EA5C5);  // Bleu océan (logo)
  static const Color accent         = Color(0xFFD4561A);  // Orange brûlé (hover/pressed)
  static const Color surface        = Color(0xFF0F1610);

  // ── Textes ────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF0EDE6);  // Ivoire sable chaud
  static const Color textSecondary  = Color(0xB3C4BAA8);  // Sable 70 %
  static const Color textHint       = Color(0x80C4BAA8);  // Sable 50 %

  // ── Glassmorphism — teinte orange subtile (signature Mayi) ────────────────
  static const Color glassFill      = Color(0x12FFFFFF);  // Blanc 7 %
  static const Color glassFillMed   = Color(0x1EFFFFFF);  // Blanc 12 %
  static const Color glassFillStrong= Color(0x2AFFFFFF);  // Blanc 16 %
  static const Color glassBorder    = Color(0x2EE8821A);  // Orange 18 % → bordure signature

  // ── Dégradés ──────────────────────────────────────────────────────────────

  // Fond principal : nuit de plage (quasi-noir avec touche forêt)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0D0B), Color(0xFF0E1A0F), Color(0xFF0A0D0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Vert palmier
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A5C2E), Color(0xFF2EA855)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Coucher de soleil (orange → orange brûlé) — boutons principaux
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFE8821A), Color(0xFFD4561A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dégradé signature : soleil → palmier → océan
  static const LinearGradient sunsetOceanGradient = LinearGradient(
    colors: [Color(0xFFE8821A), Color(0xFF1A5C2E), Color(0xFF0EA5C5)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Alias conservés pour ne pas casser les usages existants
  static const LinearGradient goldGradient = secondaryGradient;

  // Dégradé vague coucher de soleil — splash footer + décorations
  static const LinearGradient sunriseWaveGradient = LinearGradient(
    colors: [Color(0xFFFF9A3C), Color(0xFFE8821A), Color(0xFFCF5C10)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dégradé vertical chaud — utilisé pour les overlays de cartes
  static const LinearGradient warmOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0x80E8821A), Color(0xCC0C0906)],
    stops: [0.25, 0.65, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Palette Light — plage en plein soleil ─────────────────────────────────
  static const Color lightBackground     = Color(0xFFF8F4EE);  // Sable chaud
  static const Color lightBackgroundMid  = Color(0xFFEDE6DA);  // Sable foncé
  static const Color lightBackgroundCard = Color(0xFFFFFFFF);  // Blanc pur
  static const Color lightTextPrimary    = Color(0xFF1C1410);  // Quasi-noir chaud
  static const Color lightTextSecondary  = Color(0xFF6B5E4E);  // Brun sable
  static const Color lightTextHint       = Color(0xFF9B8E7E);  // Sable clair
  static const Color lightGlassFill      = Color(0xCCFFFFFF);  // Blanc 80 %
  static const Color lightGlassFillMed   = Color(0xE6FFFFFF);  // Blanc 90 %
  static const Color lightGlassBorder    = Color(0x33E8821A);  // Même bordure orange

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F4EE), Color(0xFFEDE6DA), Color(0xFFF8F4EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
