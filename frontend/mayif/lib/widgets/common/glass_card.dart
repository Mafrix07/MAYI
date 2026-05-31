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
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor ?? AppColors.glassFill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
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
    return Stack(
      children: [
        // Dégradé de base
        Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        ),

        if (showOrbs) ...[
          // Orb vert supérieur droit
          Positioned(
            top: -80,
            right: -80,
            child: _Orb(size: 280, color: AppColors.primary.withValues(alpha: 0.18)),
          ),
          // Orb or central gauche
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: -60,
            child: _Orb(size: 200, color: AppColors.secondary.withValues(alpha: 0.07)),
          ),
          // Orb vert bas droit
          Positioned(
            bottom: 80,
            right: -40,
            child: _Orb(size: 180, color: AppColors.primaryLight.withValues(alpha: 0.12)),
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
