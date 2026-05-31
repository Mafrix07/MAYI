import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/glass_card.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo clipé en cercle avec lueur dorée pulsante
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.55),
                      width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      blurRadius: 50,
                      spreadRadius: 16,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.35),
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.travel_explore,
                        color: AppColors.secondary,
                        size: 60),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.06, 1.06),
                    duration: 1200.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 32),

              // Nom app
              const Text(
                'Mayi Togo',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 8),

              const Text(
                'Découvrez le Togo 🇹🇬',
                style: TextStyle(color: AppColors.secondary, fontSize: 16),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

              const SizedBox(height: 60),

              // Indicateur de chargement stylisé
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.glassBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 3,
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
