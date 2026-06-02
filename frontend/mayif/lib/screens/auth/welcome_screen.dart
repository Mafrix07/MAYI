import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../widgets/common/glass_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // ── Brand section ────────────────────────────────────────
                Column(
                  children: [
                    // Logo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.6),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.40),
                            blurRadius: 48,
                            spreadRadius: 12,
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
                              size: 48),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.75, 0.75), curve: Curves.easeOut),

                    const SizedBox(height: 28),

                    // "Mayi" — titre gradient signature
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.sunsetOceanGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'Mayi',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                    // "T O G O" — spaced, airy
                    Text(
                      'T  O  G  O',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: context.secondaryText,
                        fontSize: 15,
                        letterSpacing: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ).animate().fadeIn(delay: 320.ms, duration: 500.ms),

                    const SizedBox(height: 22),

                    // Séparateur orange
                    Center(
                      child: Container(
                        width: 48,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                        ),
                      ).animate().scaleX(begin: 0.0, end: 1.0, delay: 420.ms, duration: 400.ms),
                    ),

                    const SizedBox(height: 16),

                    // Tagline "Explorez · Réservez · Vivez"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildTagline(context),
                    ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
                  ],
                ),

                const Spacer(flex: 3),

                // ── Boutons ──────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Se connecter — gradient avec ombre
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.secondaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.25, end: 0.0, duration: 450.ms),

                    const SizedBox(height: 14),

                    // Créer un compte — outlined avec bordure orange
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primaryText,
                        side: BorderSide(
                            color: AppColors.secondary.withValues(alpha: 0.55),
                            width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        'Créer un compte',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.25, end: 0.0, duration: 450.ms),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTagline(BuildContext context) {
    const items = ['Explorez', '·', 'Réservez', '·', 'Vivez'];
    return items.map((word) {
      final isDot = word == '·';
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDot ? 6.0 : 2.0),
        child: Text(
          word,
          style: TextStyle(
            color: isDot ? AppColors.secondary : context.secondaryText,
            fontSize: isDot ? 18 : 12,
            fontWeight: isDot ? FontWeight.bold : FontWeight.w500,
            letterSpacing: isDot ? 0 : 0.8,
          ),
        ),
      );
    }).toList();
  }
}
