import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final auth = context.read<AuthProvider>();
  final success = await auth.login(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );

  if (!mounted) return;

  if (success) {
  final role = auth.role;

  if (role == 'PROFESSIONNEL') {
    Navigator.pushReplacementNamed(context, '/dashboard-pro');

  } else if (role == 'STAFF' || role == 'ADMIN') {
    // Ouvrir le dashboard Django dans le navigateur
    final token = auth.token;

    final url = Uri.parse('http://127.0.0.1:8000/dashboard/auto-login/?token=$token');
    if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
    // Rester sur LoginScreen (pas de redirection Flutter)
    setState(() => _errorMessage = null);

  } else {
    // TOURISTE
    Navigator.pushReplacementNamed(context, '/home');
  }
}

  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond avec overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1541411133283-42e77b102925?q=80&w=1000&auto=format&fit=crop',
                ), // Paysage Togo
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Hero(
                    tag: 'logo',
                    child: Image.asset('assets/images/logo.png', height: 120),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 20),
                  Text(
                    'Bienvenue au Togo 🌍',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                  Text(
                    'L\'aventure vous attend',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),

                  // Formulaire avec Glassmorphism
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'votre@email.com',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          hint: '********',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        CustomButton(
                          text: 'Se connecter',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 30),

                  // Séparateur
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou continuer avec',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Social Login UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton('assets/images/google.png', () {}),
                      const SizedBox(width: 20),
                      _socialButton('assets/images/facebook.png', () {}),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Lien Inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore membre ? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.account_circle_outlined,
          size: 30,
          color: AppColors.textSecondary,
        ), // Placeholder for social icons
      ),
    );
  }
}
