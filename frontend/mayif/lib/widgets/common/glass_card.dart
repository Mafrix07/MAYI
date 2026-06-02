import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blurStrength;
  final Color? fillColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.blurStrength = 14,
    this.fillColor,
    this.borderColor,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultFill = isDark ? AppColors.glassFill : AppColors.lightGlassFill;
    final defaultBorder = isDark ? AppColors.glassBorder : AppColors.lightGlassBorder;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor ?? defaultFill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? defaultBorder,
                width: 1.2,
              ),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Fond avec dégradé + orbs décoratifs pour les écrans principaux
class NatureBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;

  const NatureBackground({super.key, required this.child, this.showOrbs = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Dégradé de base selon le thème
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.backgroundGradient
                : AppColors.lightBackgroundGradient,
          ),
        ),

        if (showOrbs) ...[
          // Orb solaire — haut droite (plus grand en light)
          Positioned(
            top: -120,
            right: -120,
            child: _Orb(
              size: isDark ? 340 : 420,
              color: AppColors.secondary.withValues(alpha: isDark ? 0.10 : 0.18),
            ),
          ),
          // Halo solaire central — light mode uniquement
          if (!isDark)
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: Center(
                child: _Orb(
                  size: 460,
                  color: AppColors.secondary.withValues(alpha: 0.06),
                ),
              ),
            ),
          // Orb bleu océan — milieu gauche
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            left: -90,
            child: _Orb(
              size: isDark ? 240 : 300,
              color: AppColors.ocean.withValues(alpha: isDark ? 0.07 : 0.12),
            ),
          ),
          // Orb vert palmier — bas droit
          Positioned(
            bottom: 40,
            right: -60,
            child: _Orb(
              size: isDark ? 220 : 280,
              color: AppColors.primary.withValues(alpha: isDark ? 0.13 : 0.20),
            ),
          ),
          // Orb corail — bas gauche (light uniquement)
          if (!isDark)
            Positioned(
              bottom: -40,
              left: -60,
              child: _Orb(
                size: 200,
                color: AppColors.accent.withValues(alpha: 0.10),
              ),
            ),
        ],

        // Contenu
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
