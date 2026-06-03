import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glass_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final auth    = context.read<AuthProvider>();
    final success = await auth.login(email, password);

    if (!mounted) return;

    if (success) {
      final role = auth.role;
      if (role == 'PROFESSIONNEL') {
        Navigator.pushReplacementNamed(context, '/dashboard-pro');
      } else if (role == 'STAFF' || role == 'ADMIN') {
        try {
          final codeResponse = await ApiService.post('/auth/dashboard-code/', {});
          if (codeResponse.statusCode == 200) {
            final data = jsonDecode(codeResponse.body);
            final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
            final url = Uri.parse('$baseUrl/dashboard/auto-login/?code=${data['code']}');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          }
        } catch (_) {}
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _errorMessage = auth.errorMessage);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Image de fond Togo ───────────────────────────────────
          Image.asset(
            'assets/images/monument_1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.background,
            ),
          ),

          // ── 2. Overlay adaptatif selon le thème ─────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF071A0B).withValues(alpha: isDark ? 0.45 : 0.15),
                  const Color(0xFF071A0B).withValues(alpha: isDark ? 0.75 : 0.45),
                  const Color(0xFF071A0B).withValues(alpha: isDark ? 0.97 : 0.80),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── 3. Contenu ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Logo avec halo doré
                    _LogoWithGlow()
                        .animate()
                        .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // Titre principal
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.sunsetOceanGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'MAYI',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 500.ms)
                        .slideY(begin: 0.25, curve: Curves.easeOut),

                    const SizedBox(height: 6),

                    Text(
                      'L\'aventure vous attend 🚗',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                    const SizedBox(height: 48),

                    // Card glassmorphism
                    _LoginCard(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      errorMessage: _errorMessage,
                      isLoading: _isLoading,
                      onLogin: _handleLogin,
                    )
                        .animate()
                        .fadeIn(delay: 550.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.35,
                          end: 0,
                          delay: 550.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 28),

                    // Lien inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore membre ? ',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: Text(
                            'S\'inscrire',
                            style: GoogleFonts.poppins(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo avec halo doré ────────────────────────────────────────────────────
class _LogoWithGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.45),
                    blurRadius: 70,
                    spreadRadius: 24,
                  ),
                ],
              ),
            ),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.6),
                  width: 1.8,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.35),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Togo Tourism',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.secondary.withValues(alpha: 0.7),
            fontSize: 13,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

// ── Card glassmorphism ─────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.errorMessage,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF071A0B).withValues(alpha: 0.55)
        : const Color(0xFFF5EFE8).withValues(alpha: 0.88);
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.lightGlassBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Connexion',
                style: GoogleFonts.playfairDisplay(
                  color: titleColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Accédez à votre espace Mayi',
                style: GoogleFonts.poppins(
                  color: subtitleColor,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              GlassField(
                controller: emailController,
                hint: 'Email ou nom d\'utilisateur',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              GlassField(
                controller: passwordController,
                hint: 'Mot de passe',
                icon: Icons.lock_outline_rounded,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: subtitleColor,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Mot de passe oublié ?',
                    style: GoogleFonts.poppins(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              CustomButton(
                text: 'Se connecter',
                onPressed: onLogin,
                isLoading: isLoading,
                gradient: AppColors.goldGradient,
                textColor: AppColors.background,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: Divider(color: dividerColor, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Togo Tourism',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.secondary.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: dividerColor, thickness: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
