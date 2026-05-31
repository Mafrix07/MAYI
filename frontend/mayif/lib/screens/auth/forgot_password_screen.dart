import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/glass_field.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = 'Veuillez entrer votre email.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await ApiService.post(
          '/auth/password-reset/', {'email': email});

      if (response.statusCode == 200) {
        setState(() {
          _isSuccess = true;
          _message =
              'Un email de réinitialisation a été envoyé à $email';
        });
      } else {
        setState(() {
          _isSuccess = false;
          _message =
              'Impossible de trouver un compte avec cet email.';
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = 'Erreur réseau. Veuillez réessayer.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond image avec fallback
          Image.asset(
            'assets/images/monument_1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.background),
          ),
          // Overlay dégradé sombre
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF071A0B).withValues(alpha: 0.55),
                  const Color(0xFF071A0B).withValues(alpha: 0.80),
                  const Color(0xFF071A0B).withValues(alpha: 0.97),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Bouton retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Mot de passe\noublié ?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Entrez votre email pour recevoir\nun lien de réinitialisation.',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),

                  const SizedBox(height: 48),

                  // Card glassmorphisme
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF071A0B)
                              .withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.secondary
                                .withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réinitialisation',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nous vous enverrons un lien sécurisé',
                              style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 28),

                            GlassField(
                              controller: _emailController,
                              hint: 'votre@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            if (_message != null) ...[
                              const SizedBox(height: 16),
                              GlassCard(
                                borderRadius: 12,
                                fillColor: _isSuccess
                                    ? AppColors.primary
                                        .withValues(alpha: 0.2)
                                    : Colors.red
                                        .withValues(alpha: 0.15),
                                borderColor: _isSuccess
                                    ? AppColors.primaryLight
                                        .withValues(alpha: 0.4)
                                    : Colors.redAccent
                                        .withValues(alpha: 0.4),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isSuccess
                                          ? Icons.check_circle_outline
                                          : Icons.error_outline,
                                      color: _isSuccess
                                          ? AppColors.primaryLight
                                          : Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _message!,
                                        style: TextStyle(
                                          color: _isSuccess
                                              ? AppColors.primaryLight
                                              : Colors.redAccent,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            CustomButton(
                              text: _isSuccess
                                  ? 'Retour au Login'
                                  : 'Envoyer le lien',
                              onPressed: _isSuccess
                                  ? () => Navigator.pop(context)
                                  : _handleReset,
                              isLoading: _isLoading,
                              gradient: AppColors.goldGradient,
                              textColor: AppColors.background,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
