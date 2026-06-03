import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/glass_card.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: Stack(
          children: [
            // ── Contenu principal centré ─────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo avec halo pulsant
                  Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.55),
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.45),
                          blurRadius: 60,
                          spreadRadius: 20,
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
                            size: 62),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.07, 1.07),
                        duration: 1400.ms,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 40),

                  // Titre avec gradient 3 couleurs signature Mayi
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.sunsetOceanGradient.createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'MAYI TOGO',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                  const SizedBox(height: 12),

                  // Ligne décorative orange
                  Container(
                    width: 64,
                    height: 2.5,
                    decoration: const BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 450.ms)
                      .scaleX(begin: 0.0, end: 1.0, delay: 450.ms, duration: 450.ms, curve: Curves.easeOut),

                  const SizedBox(height: 14),

                  // Tagline
                  Text(
                    'L\'hospitalité togolaise',
                    style: GoogleFonts.poppins(
                      color: AppColors.secondary.withValues(alpha: 0.80),
                      fontSize: 13,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate().fadeIn(delay: 550.ms, duration: 600.ms),
                ],
              ),
            ),

            // ── Vague footer orange ──────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _WaveClipper(),
                child: Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: AppColors.sunriseWaveGradient,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36, 44, 36, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(alpha: 0.30),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'v1.0  ·  Mayi Togo',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .slideY(begin: 1.0, end: 0.0, delay: 100.ms, duration: 700.ms, curve: Curves.easeOut)
                  .fadeIn(delay: 100.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.42);
    path.cubicTo(
      size.width * 0.15, size.height * 0.10,
      size.width * 0.35, size.height * 0.08,
      size.width * 0.50, size.height * 0.28,
    );
    path.cubicTo(
      size.width * 0.65, size.height * 0.48,
      size.width * 0.82, size.height * 0.42,
      size.width, size.height * 0.22,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
