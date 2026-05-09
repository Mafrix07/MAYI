import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF006B3F);      // Vert profond Togo
  static const Color secondary = Color(0xFFFFCD00);    // Or/Jaune soleil
  static const Color accent = Color(0xFFCC0001);       // Rouge passion
  static const Color background = Color(0xFFF8F9FA);   // Blanc cassé doux
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF006B3F), Color(0xFF00A86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFFCD00), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
